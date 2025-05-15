package unsplash

import (
	"encoding/json"
	"fmt"
	"image"
	"io"
	"net/http"
	"net/url"
	"time"

	"fds-flock-of-fetchers/fetchers"
)

type APIError struct {
	s string
}

func (e *APIError) Error() string {
	return e.s
}

func NewAPIError(s string) *APIError {
	return &APIError{s}
}

const (
	apiEndpoint = "https://api.unsplash.com/"
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

	fetchers.Downloadable
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

// The Unsplash client. Specifically, it only requests and interacting with the
// API version v1 of the Unsplash API service.
type Client struct {
	client *http.Client

	// A function with the typical workflow to be done to the request.
	// Typically this is where you can modify the headers with its required
	// values (e.g., authentication tokens) without the user worrying about it.
	requestFilter func(r *http.Request)

	fetchers.ClientInterface
}

func (c *Client) APIEndpoint() (*url.URL, error) {
	return url.Parse(apiEndpoint)
}

func (c *Client) Request(path, method string, body io.Reader) (*http.Response, error) {
	endpoint, err := url.Parse(fmt.Sprintf("%s/%s", apiEndpoint, path))
	if err != nil {
		return nil, err
	}

	req, err := http.NewRequest(method, endpoint.String(), body)
	if err != nil {
		return nil, err
	}

	c.requestFilter(req)

	return c.client.Do(req)
}

// Get an image resource from Unsplash by its ID.
func (c *Client) GetPhoto(id string) (*Photo, error) {
	res, err := c.Request(fmt.Sprintf("/photos?%s", id), "GET", nil)
	if err != nil {
		return nil, err
	}
	defer res.Body.Close()

	var v *Photo
	dec := json.NewDecoder(res.Body)
	if err := dec.Decode(v); err != nil {
		return nil, err
	}

	return v, nil
}

// Create a new Unsplash client with all of the required context to add for the
// service.
func NewClient(clientID string) *Client {
	return &Client{
		client: http.DefaultClient,
		requestFilter: func(r *http.Request) {
			r.Header.Set("User-Agent", fetchers.UserAgent)
			r.Header.Set("Authorization", fmt.Sprintf("Client-ID %s", clientID))
			r.Header.Set("Accept-Version", "v1")
			r.Header.Set("Accept", "*/*")
		},
	}
}
