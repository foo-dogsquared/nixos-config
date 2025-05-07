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

func ExtractIcon(r io.Reader, u string) ([]Icon, error) {
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
							var manifest WebManifest

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
								icons = append(icons, NewIcon(v.src, v.sizes))
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
					case "fluid-icon":
						fallthrough
					// The canonical way.
					case "icon":
						hasSizeAttr := slices.IndexFunc(token.Attr, func(a html.Attribute) bool { return a.Key == "sizes" })
						iconSize := GetOrDefault(token.Attr, hasSizeAttr, html.Attribute{Key: "size", Val: ""})
						icons = append(icons, NewIcon(token.Attr[hasHrefAttr].Val, iconSize.Val))
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

type WebManifest struct {
	name      string            `json:","`
	shortName string            `json:"short_name"`
	icons     []WebManifestIcon `json:","`
}

type WebManifestIcon struct {
	src   string `json:","`
	sizes string `json:","`
}

type Icon struct {
	path  string
	sizes []uint
}

func NewIcon(path string, size string) Icon {
	return Icon{
		path:  path,
		sizes: ParseSize(size),
	}
}

func FindLargestIcon(icons []Icon) Icon {
	var largestIconSize uint
	var icon Icon

	for _, i := range icons {
		for _, size := range i.sizes {
			if largestIconSize < size {
				largestIconSize = size
				icon = i
			}
		}
	}

	return icon
}

// Return all of icons with square sizes.
func ParseSize(s string) []uint {
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

func GetOrDefault[T any](arr []T, index int, defaultValue T) T {
	if index < 0 || index >= len(arr) {
		return defaultValue
	}
	return arr[index]
}
