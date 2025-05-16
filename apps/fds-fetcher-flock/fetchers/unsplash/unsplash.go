package unsplash

import (
	"fmt"
	"io"
	"net/http"
	"net/url"

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
	return fetchers.DefaultJsonRequestImpl[*Photo](c)(fmt.Sprintf("/photos?%s", id), nil)
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
