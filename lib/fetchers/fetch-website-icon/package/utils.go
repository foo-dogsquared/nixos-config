package main

import (
	"crypto/sha256"
	"io"

	"github.com/danielgatis/go-findfont/findfont"
)

// Given a name of the font, search through a list of fonts configured through
// fontconfig and return a list of valid fonts.
func findFont(fontName string) ([][]string, error) {
	return findfont.Find(fontName, findfont.FontRegular)
}

// A simple function equivalent of `math.Abs()` for integers.
func intAbs(x int) int {
	if x > 0 { return x } else { return -x }
}

// Given a string, convert it as a hash string with the preferred hash
// function.
func convertToHash(presetSeed string) string {
	h := sha256.New()
    io.WriteString(h, presetSeed)

	return string(h.Sum(nil))
}
