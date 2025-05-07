package main

import (
	"fmt"
	"net/http"
	"net/url"
)

type Downloader interface {
	Download() (*http.Response, error)
	URL() (*url.URL, error)
}

func DefaultDownload(dd Downloader) (*http.Response, error) {
	u, err := dd.URL()
	if err != nil {
		return nil, err
	}

	return http.Get(u.String())
}

type GoogleDownloader struct {
	domain string
	size   uint
}

func (gd *GoogleDownloader) Download() (*http.Response, error) {
	return DefaultDownload(gd)
}

func (gd *GoogleDownloader) URL() (*url.URL, error) {
	return url.Parse(fmt.Sprintf("https://www.google.com/s2/favicons?domain=%s&sz=%d", gd.domain, gd.size))
}

type DuckduckgoDownloader struct {
	domain string
}

func (ddgd *DuckduckgoDownloader) URL() (*url.URL, error) {
	return url.Parse(fmt.Sprintf("https://icons.duckduckgo.com/ip3/%s.ico", ddgd.domain))
}

func (ddgd *DuckduckgoDownloader) Download() (*http.Response, error) {
	return DefaultDownload(ddgd)
}

type FaviconExtractorDownloader struct {
	domain string
}

func (fed *FaviconExtractorDownloader) Download() (*http.Response, error) {
	return DefaultDownload(fed)
}

func (fed *FaviconExtractorDownloader) URL() (*url.URL, error) {
	return url.Parse(fmt.Sprintf("https://faviconextractor.com/favicon/%s", fed.domain))
}
