package cmd

import (
	"fmt"
	"io"
	"os"
	"path"

	"github.com/spf13/cobra"
	"github.com/spf13/viper"
)

var (
	rootCmd = &cobra.Command{
		Use: "fds-flock-of-fetchers",
		Short: "Specialized utility for foodogsquared's custom Nix fetchers",
		Long: `fds-fetcher-flock is a set of utilities specifically
suited for integrating with foodogsquared's custom Nix fetchers.

This can also be used as a standalone program for fetching assets from
several website sources such as Software Heritage, Pexels, Pixabay, and
Internet Archive.`,
	}

	ffofViper = viper.New()

	// The user provided configuration.
	cfgFile string

	// The output directory where the downloaded files will be placed.
	outputDir string
)

func Execute() error {
	return rootCmd.Execute()
}

func init() {
	cobra.OnInitialize(initConfig)

	rootCmd.PersistentFlags().StringVarP(&cfgFile, "config", "c", "", "configuration file for the application")
	rootCmd.PersistentFlags().StringVarP(&outputDir, "output-dir", "o", "", "directory where the output will be placed")
}

func initConfig() {
	if cfgFile != "" {
		ffofViper.SetConfigFile(cfgFile)
	} else {
		home, err := os.UserHomeDir()
		cobra.CheckErr(err)

		ffofViper.AddConfigPath(home)
		ffofViper.SetConfigType("toml")
		ffofViper.SetConfigName("ffof")
	}

	ffofViper.SetEnvPrefix("FOODOGSQUARED_FFOF")
	ffofViper.AutomaticEnv()

	if err := ffofViper.ReadInConfig(); err == nil {
		fmt.Println("Using config file:", viper.ConfigFileUsed())
	}
}

// A very generic download function.
func downloadFile(r io.Reader, u string) error {
	fn := path.Base(u)
	f, err := os.Create(path.Join(outputDir, fn))
	if err != nil { return err }
	defer f.Close()

	if _, err := f.ReadFrom(r); err != nil {
		return err
	}

	return nil
}
