package pexels

import (
	"fds-flock-of-fetchers/fetchers"
	"fmt"
	"math"
	"net/url"
	"reflect"
	"unicode"
)

// Find the closest asset given its width and height. A value less than zero
// means it is basically finding the maximum width possible.
func findClosestSize[T fetchers.TwoDimensional](width, height float64, objs []T) T {
	var o T

	if width < 0 {
		width = math.MaxFloat64
	}

	if height < 0 {
		height = math.MaxFloat64
	}

	for _, obj := range objs {
		if width >= obj.GetWidth() || height >= obj.GetHeight() {
			o = obj
		}
	}

	return o
}

// Following code was based from https://github.com/kosa3/pexels-go.
// Copyright © 2021 kosa3
// Generate query values based from the given struct.
func generateQueryValues(o any) *url.Values {
	q := url.Values{}

	// Returning early.
	v := reflect.ValueOf(o)
	if v.IsNil() {
		return &q
	}

	// Since we require an struct in the first place, this is pretty much
	// safe... right?
	el := v.Elem()

	for i := range el.NumField() {
		if !el.Field(i).IsZero() {
			q.Set(toSnakeCase(el.Type().Field(i).Name), fmt.Sprint(el.Field(i)))
		}
	}

	return &q
}

func toSnakeCase(s string) string {
	var result []rune
	var prevChar rune

	for i, r := range s {
		if i == 0 {
			result = append(result, unicode.ToLower(r))
			prevChar = r
			continue
		}

		if unicode.IsUpper(r) && unicode.IsLower(prevChar) {
			result = append(result, '_')
		}

		result = append(result, unicode.ToLower(r))
		prevChar = r
	}

	return string(result)
}
