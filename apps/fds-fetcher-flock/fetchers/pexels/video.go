package pexels

import (
	"fds-flock-of-fetchers/fetchers"
	"fmt"
	"image"
	"net/http"
	"strconv"
)

type Video struct {
	// The unique identifier of the video in Pexels service.
	ID apiIDType `json:"id"`

	// Width in pexels.
	Width int `json:"width"`

	// Height in pexels.
	Height int `json:"height"`

	// The user-facing URL in Pexels website.
	URL string `json:"url"`

	// Duration of the video in seconds.
	Duration int `json:"duration"`

	// The associated user account of the video.
	User *User `json:"user"`

	// A list of files with different sizes and quality.
	Files []*VideoFile `json:"video_files"`
}

func (v *Video) FilenameTemplate() string {
	return fmt.Sprintf("pexels-video-%d", v.ID)
}

func (v *Video) RequestFile(dlOpts map[string]string) (*http.Response, error) {
	var width, height int

	if v, ok := dlOpts["width"]; !ok {
		width = -1
	} else {
		w, err := strconv.Atoi(v)
		if err != nil { return nil, err }
		width = w
	}

	if v, ok := dlOpts["height"]; !ok {
		height = -1
	} else {
		h, err := strconv.Atoi(v)
		if err != nil { return nil, err }
		height = h
	}

	vf := findClosestSize(float64(width), float64(height), v.Files)

	return http.Get(vf.Link)
}

func (v *Video) DownloadFile(dlOpts map[string]string, outputDir string) error {
	return fetchers.DefaultDownloadFile(v)(dlOpts, outputDir)
}

func (v *Video) GetWidth() float64 {
	return float64(v.Width)
}

func (v *Video) GetHeight() float64 {
	return float64(v.Height)
}

func (v *Video) Rectangle() image.Rectangle {
	return image.Rect(0, 0, v.Width, v.Height)
}

func (v *Video) GetAffiliationLine() string {
	return fmt.Sprintf("<%s> by '%s' (%s)", v.User.URL, v.User.Name, v.User.URL)
}

type VideoFile struct {
	ID apiIDType `json:"id"`

	// Width in pixels.
	Width int `json:"width"`

	// Height in pixels.
	Height int `json:"height"`

	// Video format.
	FileType string `json:"file_type"`

	// The URL of the video.
	Link string `json:"link"`

	// Number of frames-per-second of the video.
	FPS float64 `json:"fps"`
}

func (vf *VideoFile) GetHeight() float64 {
	return float64(vf.Height)
}

func (vf *VideoFile) GetWidth() float64 {
	return float64(vf.Width)
}

func (vf *VideoFile) Rectangle() image.Rectangle {
	return image.Rect(0, 0, vf.Width, vf.Height)
}

// The user object in Pexels API service.
type User struct {
	// The unique identifer of the user in the Pexels website.
	ID apiIDType `json:"id"`

	// The name of the user.
	Name string `json:"name"`

	// The Pexels URL of the user.
	URL string `json:"url"`
}
