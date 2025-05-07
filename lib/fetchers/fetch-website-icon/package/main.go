package main

import (
	"flag"
	"fmt"
	"io"
	"log"
	"net/http"
	"net/url"
	"os"
	"path"
	"path/filepath"
)

var size uint
var rawURL string
var outDir string
var largestOnly bool
var verbose bool

func main() {
	ArgInit()
	flag.Parse()

	if rawURL == "" {
		fmt.Println("URL is required")
		os.Exit(1)
	}

	initialUrl, err := url.Parse(rawURL)
	if err != nil {
		log.Fatal(err)
	}

	// Download from the Google hidden favicon service. This is our primary
	// service provider for the icon download.
	googleIcon := GoogleDownloader{domain: initialUrl.Host, size: size}
	res, err := googleIcon.Download()
	if err != nil {
		log.Fatal(err)
	}
	defer res.Body.Close()

	if res.StatusCode == http.StatusOK {
		SaveFile(res.Body)
		os.Exit(0)
	}

	// Next is the Duckduckgo favicon service.
	duckduckgoIcon := DuckduckgoDownloader{domain: initialUrl.Host}
	res, err = duckduckgoIcon.Download()
	if err != nil {
		log.Fatal(err)
	}
	defer res.Body.Close()

	if res.StatusCode == http.StatusOK {
		SaveFile(res.Body)
		os.Exit(0)
	}
}

func SaveFile(r io.Reader) {
	f, err := os.Create(path.Join(outDir, "icon"))
	if err != nil {
		log.Fatal(err)
	}
	defer f.Close()
	f.ReadFrom(r)
}

func DownloadFallbackIcon(icon Icon) (string, error) {
	linkURL, err := url.JoinPath(rawURL, icon.path)
	if err != nil {
		return "", err
	}

	res, err := http.Get(linkURL)
	if err != nil {
		return "", err
	}
	defer res.Body.Close()
	if res.StatusCode == http.StatusOK {
		f, err := os.Create(path.Join(outDir, filepath.Base(linkURL)))
		if err != nil {
			return "", err
		}
		defer f.Close()
		f.ReadFrom(res.Body)

		return f.Name(), nil
	}

	return "", nil
}

func ArgInit() {
	flag.StringVar(&rawURL, "url", "", "URL containing the HTML document")
	flag.UintVar(&size, "size", 256, "Size of the icon (in SIZExSIZE dimension) to be extracted")
	flag.StringVar(&outDir, "output-dir", "./", "Output directory of the icons to be downloaded")
	flag.BoolVar(&largestOnly, "largest-only", false, "Download only the largest possible size of the icon (vector format are always preferred first)")
	flag.BoolVar(&verbose, "verbose", false, "Set verbosity")
}
