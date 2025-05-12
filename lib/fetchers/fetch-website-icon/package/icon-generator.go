package main

import (
	"image"
	"image/color"
	"image/draw"
	"math/rand/v2"
	"net/url"
	"os"
	"strings"

	"golang.org/x/image/font"
	"golang.org/x/image/font/opentype"
	"golang.org/x/image/math/fixed"
)

// Generate a simple square icon consisting of a plain background and the first
// glyph of the URL hostname. This uses system fonts through fontconfig so
// you'll have to configure your environment.
func generateIcon(rawURL *url.URL, size int, fontName string) (draw.RGBA64Image, error) {
	// Setting up the background image.
	img := image.NewRGBA(image.Rect(0, 0, size, size))

	// The hostname part is case-insensitive anyways so this is fine.
	hostname := strings.ToLower(rawURL.Hostname())
	resultingHash := convertToHash(hostname)
	s := [32]byte([]byte(resultingHash))
	r := rand.New(rand.NewChaCha8(s))
	bgColor := color.RGBA{uint8(r.UintN(255)), uint8(r.UintN(255)), uint8(r.UintN(255)), 255 }
	draw.Draw(img, img.Bounds(), &image.Uniform{bgColor}, image.Point{0, 0}, draw.Src)

	// Then render the text.
	runes := []rune(hostname)
	char := runes[0]

	fonts, err := findFont(fontName)
	if err != nil || len(fontName) <= 0 { return nil, err }

	// Just see findfont package for more information about this.
	fontPath := fonts[0][2]

	err = addLabel(img, &image.Point{0, 0}, char, fontPath)
	if err != nil { return nil, err }

	return img, nil
}

// Add a label with a single rune character in the center of the image.
func addLabel(img *image.RGBA, p *image.Point, label rune, fontPath string) error {
	// We're assuming that the icons here are square.
	size := img.Bounds().Dx()

	fontBytes, err := os.ReadFile(fontPath)
	if err != nil { return err }

	_font, err := opentype.Parse(fontBytes)
	if err != nil { return err }

	fontSize := float64(size) * 0.80
	faceOptions := opentype.FaceOptions {
		Size: fontSize,
		DPI: 72,
		Hinting: font.HintingNone,
	}
	fontface, err := opentype.NewFace(_font, &faceOptions);
	if err != nil { return err }

	d := &font.Drawer{
		Dst:  img,
		Src:  image.NewUniform(color.White),
		Face: fontface,
	}

    boundingBox, _, _ := d.Face.GlyphBounds(label)
    charWidth := intAbs(boundingBox.Min.X.Ceil()) + boundingBox.Max.X.Ceil()
	charHeight := intAbs(boundingBox.Min.Y.Ceil()) + boundingBox.Max.Y.Ceil()

    startingX := (size - charWidth) / 2
	startingY := charHeight + ((size - charHeight) / 2)

	d.Dot = fixed.P(startingX, startingY)
	d.DrawString(string(label))

	return nil
}
