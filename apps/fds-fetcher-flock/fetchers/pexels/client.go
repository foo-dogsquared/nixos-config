package pexels

import (
	"fds-flock-of-fetchers/fetchers"
	"fmt"
	"io"
	"net/http"
	"net/url"
)

const (
	apiEndpoint = "https://api.pexels.com"
	apiVersion  = "v1"
)

type apiIDType uint64

// Pexels simple API client.
type Client struct {
	client *http.Client

	requestFilter func(r *http.Request)

	fetchers.ClientInterface
}

func (c *Client) APIEndpoint() (*url.URL, error) {
	return url.Parse(apiEndpoint)
}

func (c *Client) Request(path, method string, body io.Reader) (*http.Response, error) {
	u, err := url.Parse(fmt.Sprintf("%s/%s", apiEndpoint, path))
	if err != nil {
		return nil, err
	}

	fmt.Println(u.String())
	req, err := http.NewRequest(method, u.String(), body)
	if err != nil {
		return nil, err
	}

	c.requestFilter(req)

	return c.client.Do(req)
}

// Get a video resource from Pexels by its ID.
func (c *Client) GetVideo(id int) (*Video, error) {
	return fetchers.DefaultJsonRequestImpl[*Video](c)(fmt.Sprintf("videos/videos/%d", id), nil)
}

// Get a photo resource from Pexels by its ID.
func (c *Client) GetPhoto(id int) (*Photo, error) {
	return fetchers.DefaultJsonRequestImpl[*Photo](c)(fmt.Sprintf("%s/photos/%d", apiVersion, id), nil)
}

// Get the pagination resource from a given pagination object and its
// direction.
func (c *Client) Paginate(pag *Pagination, dir PaginationDirection) (*Pagination, error) {
	return fetchers.DefaultJsonRequestImpl[*Pagination](c)(pag.Paginate(dir), nil)
}

// Get the pagination resource for curated photos.
func (c *Client) GetCuratedPhotos(params *PhotoPageParams) (*Pagination, error) {
	q := generateQueryValues(params)

	return fetchers.DefaultJsonRequestImpl[*Pagination](c)(fmt.Sprintf("%s/curated?%s", apiVersion, q.Encode()), nil)
}

func (c *Client) GetPopularVideos(params *VideoPageParams) (*Pagination, error) {
	q := generateQueryValues(params)

	return fetchers.DefaultJsonRequestImpl[*Pagination](c)(fmt.Sprintf("videos/popular?%s", q.Encode()), nil)
}

func NewClient(apikey string) *Client {
	return &Client{
		client: http.DefaultClient,
		requestFilter: func(r *http.Request) {
			r.Header.Set("User-Agent", fetchers.UserAgent)
			r.Header.Set("Accept", "application/json")
			r.Header.Set("Authorization", apikey)
		},
	}
}
