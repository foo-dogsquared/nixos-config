package unsplash

import (
	"fmt"
	"fds-flock-of-fetchers/fetchers"
	"net/url"
	"net/http"
	"time"
	"image"
)

// A Unsplash photo response typically found in HTTP API response.
type Photo struct {
	// The unique identifier of the Unsplash photo.
	ID string `json:"id"`

	// The slug of the photo.
	Slug string `json:"slug"`

	// The description of the photo.
	Description string `json:"description"`

	CreatedAt    *time.Time `json:"created_at,omitempty"`
	UpdatedAt    *time.Time `json:"updated_at,omitempty"`
	Width        uint       `json:"width,omitempty"`
	Height       uint       `json:"height,omitempty"`
	BlurHash     string     `json:"blur_hash,omitempty"`
	PublicDomain bool       `json:"public_domain"`

	URLs map[string]string `json:"urls"`

	// A set of links with their related metadata.
	Links map[string]string `json:"links"`

	// The associated user account of the photo.
	User *User `json:"user"`
}

func (o *Photo) FilenameTemplate() string {
	return fmt.Sprintf("unsplash-image-%s", o.ID)
}

func (o *Photo) RequestFile(dlOpts map[string]string) (*http.Response, error) {
	u, err := url.Parse(o.URLs[dlOpts["photo-variant"]])
	if err != nil {
		return nil, err
	}

	q := u.Query()
	for n, v := range dlOpts {
		if n == "photo-variant" {
			continue
		}

		q.Set(n, v)
	}

	u.RawQuery = q.Encode()

	return http.Get(u.String())
}

func (o *Photo) DownloadFile(dlOpts map[string]string, outputDir string) error {
	return fetchers.DefaultDownloadFile(o)(dlOpts, outputDir)
}

func (o *Photo) GetWidth() float64 {
	return float64(o.Width)
}

func (o *Photo) GetHeight() float64 {
	return float64(o.Height)
}

func (o *Photo) Rectangle() image.Rectangle {
	return image.Rect(0, 0, int(o.Width), int(o.Height))
}

func (o *Photo) GetAffiliationLine() string {
	photoName := o.Description
	userName := o.User.Name

	if photoName == "" {
		photoName = fmt.Sprintf("<%s>", o.Links["html"])
	}

	if userName == "" {
		userName = o.User.Username
	}

	return fmt.Sprintf(
		"%s by '%s' <%s>",
		photoName, userName, o.User.Links["html"],
	)
}

// Unsplash user metadata.
type User struct {
	// Unique identifier of the user account in the service.
	ID string `json:"id"`

	// Legal name of the account.
	Name string `json:"name"`

	// User-facing name of the account.
	Username string `json:"username"`

	// Self-made description of the user account.
	Bio string `json:"bio"`

	// A set of links relating to the user account.
	Links map[string]string `json:"links"`
}
