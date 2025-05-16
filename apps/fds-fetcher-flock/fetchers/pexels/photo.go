package pexels

import (
	"fds-flock-of-fetchers/fetchers"
	"fmt"
	"image"
	"net/http"
	"net/url"
)

type Photo struct {
	// The unique identifier of the photo in Pexels service.
	ID apiIDType `json:"id"`

	// Width in pixels.
	Width int `json:"width"`

	// Height in pixels.
	Height int `json:"height"`

	// The HTML URL of the photo in the Pexels website.
	URL string `json:"url"`

	// Name of the photographer.
	Photographer string `json:"photographer"`

	// URL of the photographer's Pexels profile.
	PhotographerURL string `json:"photographer_url"`

	// Unique identifer of the photographer in the Pexels website.
	PhotographerID apiIDType `json:"photographer_id"`

	// A set of links with different image sizes.
	Sources map[string]string `json:"src"`

	// Text description of the photo typically used in `alt=` attribute in HTML images.
	Description string `json:"alt"`
}

func (p *Photo) Rectangle() image.Rectangle {
	return image.Rect(0, 0, p.Width, p.Height)
}

func (p *Photo) FilenameTemplate() string {
	return fmt.Sprintf("pexels-photo-%d", p.ID)
}

func (p *Photo) RequestFile(dlOpts map[string]string) (*http.Response, error) {
	size := dlOpts["photo-size"]

	if size == "" {
		size = "original"
	}

	// The image endpoint of Pexels seems to offer dynamic photos through its
	// delivery service.
	u, err := url.Parse(p.Sources[size])
	if err != nil {
		return nil, err
	}

	q := u.Query()

	for n, v := range dlOpts {
		if n == "photo-size" {
			continue
		}
		q.Set(n, v)
	}

	u.RawQuery = q.Encode()

	return http.Get(u.String())
}

func (p *Photo) DownloadFile(dlOpts map[string]string, outputDir string) error {
	return fetchers.DefaultDownloadFile(p)(dlOpts, outputDir)
}

func (p *Photo) GetAffiliationLine() string {
	return fmt.Sprintf("<%s> by '%s' (%s)", p.URL, p.Photographer, p.PhotographerURL)
}
