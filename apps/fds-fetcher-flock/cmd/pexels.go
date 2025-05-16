package cmd

import (
	"fds-flock-of-fetchers/fetchers/pexels"
	"strconv"

	"github.com/spf13/cobra"
)

var (
	pexelsCmd = &cobra.Command{
		Use:   "pexels",
		Short: "fetch assets from Pexels",
	}

	pexelsApiKey string

	pexelsFetchImagesByIdCmd = &cobra.Command{
		Use:   "photos-by-id ID [ID...]",
		Short: "fetch Pexels photos by its id",
		Args:  cobra.MinimumNArgs(1),
		Run:   runPexelsFetchImagesByIdCmd,
	}

	pexelsFetchVideosByIdCmd = &cobra.Command{
		Use: "videos-by-id ID [ID...]",
		Short: "fetch Pexels videos by its id",
		Args: cobra.MinimumNArgs(1),
		Run: runPexelsFetchVideosByIdCmd,
	}

	pexelsFetchFromCurationFeed = &cobra.Command{
		Use:   "curation-feed",
		Short: "fetch Pexels photos from curated feed",
		Run:   runPexelsFetchFromCurationFeedCmd,
	}

	pexelsFetchFromPopularVideosCmd = &cobra.Command{
		Use: "popular-videos",
		Short: "fetch videos from Pexels' popular video feed",
		Run: runPexelsFetchFromPopularVideosCmd,
	}
)

// TODO
// Fetch by ID
func runPexelsFetchImagesByIdCmd(cmd *cobra.Command, args []string) {
	apiKey := fetchPexelsApiKey()

	client := pexels.NewClient(apiKey)

	photoFormat, err := cmd.Flags().GetString("image-size")
	if err != nil {
		cobra.CheckErr(err)
	}

	dlOpts := make(map[string]string)
	dlOpts["image-size"] = photoFormat

	for _, id := range args {
		if id == "" {
			cmd.Println("given ID is empty, skipping request")
			continue
		}

		photoId, err := strconv.Atoi(id)
		if err != nil {
			cmd.Printf("given ID '%s' is not valid, skipping request", id)
			continue
		}

		photo, err := client.GetPhoto(photoId)
		if err != nil {
			cmd.PrintErr(err)
			continue
		}

		if err := photo.DownloadFile(dlOpts, outputDir); err != nil {
			cmd.PrintErr(err)
			continue
		}

		cmd.Println(photo.GetAffiliationLine())
	}
}

func runPexelsFetchVideosByIdCmd(cmd *cobra.Command, args []string) {
	apiKey := fetchPexelsApiKey()

	client := pexels.NewClient(apiKey)

	dlOpts := make(map[string]string)

	for _, id := range args {
		if id == "" {
			cmd.Println("given ID is empty, skipping request")
			continue
		}

		videoId, err := strconv.Atoi(id)
		if err != nil {
			cmd.Printf("given ID '%s' is not valid, skipping request", id)
			continue
		}

		video, err := client.GetVideo(videoId)
		if err != nil {
			cmd.PrintErr(err)
			continue
		}

		if err := video.DownloadFile(dlOpts, outputDir); err != nil {
			cmd.PrintErr(err)
			continue
		}

		cmd.Println(video.GetAffiliationLine())
	}
}

// Fetch by curated collection
func runPexelsFetchFromCurationFeedCmd(cmd *cobra.Command, args []string) {
	apiKey := fetchPexelsApiKey()

	client := pexels.NewClient(apiKey)

	perPage, err := cmd.Flags().GetUint("count")
	if err != nil { cobra.CheckErr(err) }

	page, err := client.GetCuratedPhotos(&pexels.PhotoPageParams{
		PerPage: int(perPage),
	})
	if err != nil {
		cobra.CheckErr(err)
	}

	dlOpts := make(map[string]string)
	for _, photo := range page.Photos {
		if err := photo.DownloadFile(dlOpts, outputDir); err != nil {
			cmd.PrintErrln(err)
			continue
		}

		cmd.Println(photo.GetAffiliationLine())
	}
}

func runPexelsFetchFromPopularVideosCmd(cmd *cobra.Command, args []string) {
	apiKey := fetchPexelsApiKey()
	client := pexels.NewClient(apiKey)

	perPage, err := cmd.Flags().GetUint("count")
	if err != nil { cobra.CheckErr(err) }

	videoParams := &pexels.VideoPageParams{
		PerPage: int(perPage),
	}

	if v, err := cmd.Flags().GetUint("min-width"); err == nil {
		videoParams.MinWidth = int(v)
	} else { cobra.CheckErr(err) }

	if v, err := cmd.Flags().GetUint("max-width"); err == nil {
		videoParams.MaxWidth = int(v)
	} else { cobra.CheckErr(err) }

	page, err := client.GetPopularVideos(videoParams)
	if err != nil {
		cobra.CheckErr(err)
	}

	dlOpts := make(map[string]string)

	for _, video := range page.Videos {
		if err := video.DownloadFile(dlOpts, outputDir); err != nil {
			cmd.PrintErrln(err)
			continue
		}

		cmd.Println(video.GetAffiliationLine())
	}
}

func fetchPexelsApiKey() string {
	if v := ffofViper.GetString("pexels.api_key"); v != "" {
		return v
	}

	return ffofViper.GetString("pexels_api_key")
}

func init() {
	pexelsCmd.PersistentFlags().String("image-size", "original", "image size of the fetched photos")
	pexelsCmd.PersistentFlags().StringVar(&pexelsApiKey, "api-key", "", "API key of the Pexels API service")

	pexelsFetchFromCurationFeed.Flags().Uint("count", 15, "number of photos to be downloaded (maximum of 80)")

	pexelsFetchFromPopularVideosCmd.Flags().Uint("count", 5, "number of videos to be downloaded (maximum of 80)")

	ffofViper.BindPFlag("pexels.api_key", pexelsCmd.PersistentFlags().Lookup("api-key"))
	ffofViper.BindEnv("pexels_api_key")

	pexelsCmd.AddCommand(pexelsFetchFromCurationFeed, pexelsFetchImagesByIdCmd, pexelsFetchVideosByIdCmd, pexelsFetchFromPopularVideosCmd)
	rootCmd.AddCommand(pexelsCmd)
}
