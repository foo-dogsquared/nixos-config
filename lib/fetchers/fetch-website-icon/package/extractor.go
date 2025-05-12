package main

import (
	"encoding/json"
	"io"
	"log"
	"net/http"
	"net/url"
	"slices"
	"strconv"
	"strings"

	"golang.org/x/net/html"
)

// Given a URL, extract all of the icons (`Icon`) found in the document head.
func getIconFromHTML(rawURL string) (*http.Response, error) {
	res, err := http.Get(rawURL)

	// We're also anticipating if the request is invalid (e.g., not a
	// reachable/real domain).
	if err != nil || res == nil { return res, err }
	defer res.Body.Close()

	if res.StatusCode != http.StatusOK { return res, err }

	icons, err := extractIcon(res.Body, rawURL)
	if err != nil { return nil, err }

	// This is for pages with no icons at all which basically means it's up to
	// generating our own at this point.
	if len(icons) <= 0 { return nil, nil }

	icon := findLargestIcon(icons)
	iconURL, err := url.JoinPath(rawURL, icon.path)
	if err != nil { return nil, err }

	return http.Get(iconURL)
}

// Extract all of the possible icon elements of an HTML document.
func extractIcon(r io.Reader, u string) ([]Icon, error) {
	var icons []Icon
	tokenizer := html.NewTokenizer(r)

	for {
		token := tokenizer.Next()

		switch token {
		case html.ErrorToken:
			err := tokenizer.Err()
			if err == io.EOF {
				return icons, nil
			}
			return nil, err
		case html.StartTagToken:
			token := tokenizer.Token()

			switch token.Data {
			case "link":
				hasRelAttr := slices.IndexFunc(token.Attr, func(a html.Attribute) bool { return a.Key == "rel" })
				hasHrefAttr := slices.IndexFunc(token.Attr, func(a html.Attribute) bool { return a.Key == "href" })
				if hasRelAttr != -1 && hasHrefAttr != -1 {
					switch token.Attr[hasRelAttr].Val {

					// Going to extract them from the site webmanifest which
					// might contains high-quality icons.
					case "manifest":
						manifestURL, err := url.JoinPath(u, token.Attr[hasHrefAttr].Val)
						if err != nil {
							log.Println(err)
							continue
						}

						res, err := http.Get(manifestURL)
						if err != nil {
							log.Println(err)
							continue
						}
						defer res.Body.Close()

						if res.StatusCode == http.StatusOK {
							var manifest webManifest

							body, err := io.ReadAll(res.Body)
							if err != nil {
								log.Println(err)
								continue
							}

							err = json.Unmarshal(body, &manifest)
							if err != nil {
								log.Println(err)
								continue
							}

							for _, v := range manifest.icons {
								icons = append(icons, NewIcon(v.src, v.sizes, ManifestIcon))
							}
						}
					// A bunch of common quirky ways to specify the icon
					// resource.
					case "shortcut icon":
						fallthrough
					case "icon shortcut":
						fallthrough
					case "shortcut-icon":
						fallthrough
					// Apple-specific icons which may be larger than usual.
					case "apple-touch-icon":
						fallthrough
					case "apple-touch-icon-precomposed":
						fallthrough
					// This is apparently used as part of MacOS dock icon.
					// The canonical way.
					case "icon":
						hasSizeAttr := slices.IndexFunc(token.Attr, func(a html.Attribute) bool { return a.Key == "sizes" })
						iconSize := getOrDefault(token.Attr, hasSizeAttr, html.Attribute{Key: "size", Val: ""})
						icons = append(icons, NewIcon(token.Attr[hasHrefAttr].Val, iconSize.Val, NormalIcon))
					case "fluid-icon":
						hasSizeAttr := slices.IndexFunc(token.Attr, func(a html.Attribute) bool { return a.Key == "sizes" })
						iconSize := getOrDefault(token.Attr, hasSizeAttr, html.Attribute{Key: "size", Val: ""})
						icons = append(icons, NewIcon(token.Attr[hasHrefAttr].Val, iconSize.Val, FluidIcon))
					}
				}
			// We're only going to parse the document head anyways since that
			// should where all of the icons located. Plus, an HTML document is
			// strictly required to have the head before the body so this is
			// acceptable.
			case "body":
				break
			}
		}
	}
}

type webManifest struct {
	name      string            `json:","`
	shortName string            `json:"short_name"`
	icons     []webManifestIcon `json:","`
}

type webManifestIcon struct {
	src   string `json:","`
	sizes string `json:","`
}

type IconType uint
const (
	NormalIcon IconType = iota
	FluidIcon
	ManifestIcon
)

type Icon struct {
	path  string
	sizes []uint
	priority IconType
}

func NewIcon(path string, size string, iconType IconType) Icon {
	return Icon{
		path:  path,
		sizes: parseSize(size),
		priority: iconType,
	}
}

// Find the possible largest icon in the icon list.
//
// As an implementation detail, this function doesn't do any downloading and
// can only look at the possible data without the inspecting the image file on
// the remote side. We also sort this from our list of priorities (from
// `IconType`). All in all, this function could be entirely wrong.
func findLargestIcon(icons []Icon) Icon {
	var (
		largestIconSize uint
		icon Icon
	)

	for _, i := range icons {
		if len(i.sizes) > 0 {
			for _, size := range i.sizes {
				if largestIconSize < size {
					largestIconSize = size
					icon = i
				}
			}
		} else if i.priority > icon.priority {
			icon = i
		}
	}

	return icon
}

// Return all of icons with square sizes.
func parseSize(s string) []uint {
	sizes := strings.Split(s, " ")

	var result []uint

	for _, v := range sizes {
		v = strings.ToLower(v)
		dimensions := strings.Split(v, "x")

		// Accept only square icons.
		if len(dimensions) != 2 || dimensions[0] != dimensions[1] {
			continue
		}

		size, err := strconv.Atoi(dimensions[0])
		if err != nil {
			continue
		}
		result = append(result, uint(size))
	}

	return result
}

func getOrDefault[T any](arr []T, index int, defaultValue T) T {
	if index < 0 || index >= len(arr) {
		return defaultValue
	}
	return arr[index]
}
