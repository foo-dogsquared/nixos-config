package unsplash

import (
	"fmt"
	"io"
	"net/http"
	"net/url"
	"os"
	"path"
	"time"

	"fds-flock-of-fetchers/fetchers"
)

type UnsplashAPIError struct {
	s string
}

func (e *UnsplashAPIError) Error() string {
	return e.s
}

func NewUnsplashAPIError(s string) *UnsplashAPIError {
	return &UnsplashAPIError{s}
}

const (
	unsplashApiEndpoint = "https://api.unsplash.com/"
)

// A Unsplash photo response typically found in HTTP API response.
type UnsplashPhoto struct {
	// The unique identifier of the Unsplash photo.
	ID string `json:"id"`

	// The slug of the photo.
	Slug string `json:"slug"`

	// The description of the photo.
	Description string `json:"description"`

	CreatedAt *time.Time `json:"created_at,omitempty"`
	UpdatedAt *time.Time `json:"updated_at,omitempty"`
	Width uint `json:"width,omitempty"`
	Height uint `json:"height,omitempty"`
	BlurHash string `json:"blur_hash,omitempty"`
	PublicDomain bool `json:"public_domain"`

	URLs map[string]string `json:"urls"`

	// A set of links with their related metadata.
	Links map[string]string `json:"links"`

	// The associated user account of the photo.
	User *UnsplashUser `json:"user"`

	fetchers.Downloadable
}

func (o *UnsplashPhoto) FilenameTemplate() string {
	return fmt.Sprintf("unsplash-image-%s", o.ID)
}

func (o *UnsplashPhoto) RequestFile(dlOpts map[string]string) (*http.Response, error) {
	u, err := url.Parse(o.URLs[dlOpts["photo-variant"]])
	if err != nil { return nil, err }

	q := u.Query()
	for n, v := range dlOpts {
		if n == "photo-variant" { continue }

		q.Set(n, v)
	}

	u.RawQuery = q.Encode()

	return http.Get(u.String())
}

func (o *UnsplashPhoto) DownloadFile(dlOpts map[string]string, outputDir string) error {
	fn := o.FilenameTemplate()
	f, err := os.Create(path.Join(outputDir, fn))
	if err != nil { return err }
	defer f.Close()

	res, err := o.RequestFile(dlOpts)
	if err != nil { return err }
	defer res.Body.Close()

	if _, err := f.ReadFrom(res.Body); err != nil {
		return err
	}

	return nil
}

// Unsplash user metadata.
type UnsplashUser struct {
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
type UnsplashClient struct {
	client *http.Client

	// A function with the typical workflow to be done to the request.
	// Typically this is where you can modify the headers with its required
	// values (e.g., authentication tokens) without the user worrying about it.
	requestFilter func(r *http.Request)

	fetchers.ClientInterface
}

func (c *UnsplashClient) APIEndpoint() (*url.URL, error) {
	return url.Parse(unsplashApiEndpoint)
}

func (c *UnsplashClient) Request(path, method string, body io.Reader) (*http.Response, error) {
	endpoint, err := url.Parse(fmt.Sprintf("%s/%s", unsplashApiEndpoint, path))
	if err != nil { return nil, err }

	req, err := http.NewRequest(method, endpoint.String(), body)
	if err != nil { return nil, err }

	c.requestFilter(req)

	return c.client.Do(req)
}

// Create a new Unsplash client with all of the required context to add for the
// service.
func NewUnsplashClient(clientID string) *UnsplashClient {
	return &UnsplashClient{
		client: http.DefaultClient,
		requestFilter: func(r *http.Request) {
			r.Header.Set("User-Agent", fetchers.UserAgent)
			r.Header.Set("Authorization", fmt.Sprintf("Client-ID %s", clientID))
			r.Header.Set("Accept-Version", "v1")
			r.Header.Set("Accept", "*/*")
		},
	}
}
