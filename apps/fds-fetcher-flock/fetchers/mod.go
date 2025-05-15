package fetchers

import (
	"io"
	"net/url"
	"net/http"
	"os"
	"path"
)

const UserAgent string = "foodogsquared-flock-of-feathers/0.1.0 <foodogsquared@foodogsquared.one>"

type ClientInterface interface {
	Request(p, method string, body io.Reader) (*http.Response, error)
	APIEndpoint() (*url.URL, error)
}

type Downloadable interface {
	// The automatically assigned filename template associated with the downloadable object.
	FilenameTemplate() string

	// Create an HTTP request for the downloadable object.
	RequestFile(dlOpts *map[string]string) (*http.Response, error)

	// Download the file associated with the downloadable object into the filesystem.
	DownloadFile(dlOpts *map[string]string, outputDir string) error
}

// The default implementation of the fetcher download. This assumes that this
// doesn't require any payload in the request body and fully relies on the URL
// to specify the service's parameters.
func DefaultFetcherRequest(c ClientInterface, u *url.URL, method string) (*http.Response, error) {
	return c.Request(u.String(), method, nil)
}

// The default implementation for downloading a file.
func DefaultDownloadFile(dlable Downloadable, dlOpts *map[string]string, outputDir string) error {
	fn := dlable.FilenameTemplate()
	f, err := os.Create(path.Join(outputDir, fn))
	if err != nil { return err }
	defer f.Close()

	res, err := dlable.RequestFile(dlOpts)
	if err != nil { return err }
	defer res.Body.Close()

	if _, err := f.ReadFrom(res.Body); err != nil {
		return err
	}

	return nil
}
