package main

import (
	"flag"
	"fmt"
	"image/png"
	"io"
	"log"
	"net/http"
	"net/url"
	"os"
	"path"
)

var (
	rawURL string
	size uint
	outDir string
	largestOnly bool
	verbose bool
	fontName string
)

func main() {
	setupFlags()
	flag.Parse()

	if rawURL == "" {
		fmt.Println("URL is required")
		os.Exit(1)
	}

	initialUrl, err := url.Parse(rawURL)
	if err != nil {
		log.Fatal(err)
	}

	// First, we'll go through the hard way of manually finding it ourselves.
	// Take note, this is not a guaranteed case especially for dynamically
	// rendered websites (requiring JavaScript client side and all that jazz).
	downloadFromHTMLDocument(initialUrl)

	// As a fallback, download from the Google hidden favicon service. This is
	// our primary service provider for the icon download.
	downloadFromGoogleIcons(initialUrl)

	// Next is the Duckduckgo favicon service.
	downloadFromDuckduckgoIcons(initialUrl)

	// If there's really no such thing, we'll have to create our own icon
	// inspired from Icon Horse autogenerating function. This is the fallback
	// of fallbacks and should guarantee a result for this.
	generateIconFromURL(initialUrl, size, fontName)
}

func saveFile(r io.Reader) {
	f, err := os.Create(path.Join(outDir, "icon"))
	if err != nil {
		log.Fatal(err)
	}
	defer f.Close()
	f.ReadFrom(r)
}

func setupFlags() {
	flag.StringVar(&rawURL, "url", "", "URL containing the HTML document")
	flag.UintVar(&size, "size", 256, "Size of the icon (in SIZExSIZE dimension) to be extracted")
	flag.StringVar(&outDir, "output-dir", "./", "Output directory of the icons to be downloaded")
	flag.BoolVar(&largestOnly, "largest-only", false, "Download only the largest possible size of the icon (vector format are always preferred first)")
	flag.BoolVar(&verbose, "verbose", false, "Set verbosity")
	flag.StringVar(&fontName, "font", "Noto Sans Emoji", "Name of the font to be used in the fallback icon generation process")
}

func downloadFromHTMLDocument(initialUrl *url.URL) {
	res, err := getIconFromHTML(initialUrl.String())

	// Since we're requesting a domain ourselves instead of using a favicon
	// service, we'll have to make sure it is a valid response.
	if err != nil { log.Println(err) }
	if res != nil {
		defer res.Body.Close()

		if res.StatusCode == http.StatusOK {
			saveFile(res.Body)
			os.Exit(0)
		}
	}
}

func downloadFromGoogleIcons(initialUrl *url.URL) {
	googleIcon := GoogleDownloader{domain: initialUrl.Host, size: size}
	res, err := googleIcon.Download()
	if err != nil {
		log.Println(err)
	}
	defer res.Body.Close()

	if res.StatusCode == http.StatusOK {
		saveFile(res.Body)
		os.Exit(0)
	}
}

func downloadFromDuckduckgoIcons(initialUrl *url.URL) {
	duckduckgoIcon := DuckduckgoDownloader{domain: initialUrl.Host}
	res, err := duckduckgoIcon.Download()
	if err != nil { log.Println(err) }
	defer res.Body.Close()

	if res.StatusCode == http.StatusOK {
		saveFile(res.Body)
		os.Exit(0)
	}
}

func generateIconFromURL(initialUrl *url.URL, size uint, fontName string) {
	fallbackIcon, err := generateIcon(initialUrl, int(size), fontName)
	if err != nil { log.Fatal(err) }

	f, err := os.Create(path.Join(outDir, "icon"))
	if err != nil { log.Fatal(err) }
	defer f.Close()

	if err = png.Encode(f, fallbackIcon); err != nil {
		f.Close()
		log.Fatal(err)
	}
}
