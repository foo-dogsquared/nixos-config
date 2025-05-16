package pexels

import (
	"testing"
)

var (
	mockTestVideoFiles = []*VideoFile{
		{
			Width: 640,
			Height: 360,
		},

		{
			Width: 960,
			Height: 540,
		},

		{
			Width: 1280,
			Height: 720,
		},

		{
			Width: 1920,
			Height: 1080,
		},
	}
)

func TestClosestSize(t *testing.T) {
	cases := []struct{
		name string
		width float64
		height float64
		expected *VideoFile
	}{
		{
			name: "StrictLargestSize",
			width: 1920,
			height: 1020,
			expected: mockTestVideoFiles[len(mockTestVideoFiles)-1],
		},

		{
			name: "StrictSmallestSize",
			width: 640,
			height: 360,
			expected: mockTestVideoFiles[0],
		},

		{
			name: "StrictSmallestSizeWithZeroHeight",
			width: 640,
			height: 0,
			expected: mockTestVideoFiles[0],
		},

		{
			name: "LargestSizeWithNonZeroValues",
			width: -1,
			height: -1,
			expected: mockTestVideoFiles[len(mockTestVideoFiles)-1],
		},
	}

	for _, c := range cases {
		t.Run(c.name, func(t *testing.T) {
			if v := findClosestSize(c.width, c.height, mockTestVideoFiles); v != c.expected {
				t.Errorf("expected video file with '%dx%d' size, got %v", c.expected.Width, c.expected.Height, v)
			}
		})
	}
}

func TestSnakeCase(t *testing.T) {
	cases := []struct{
		name string
		input string
		expected string
	}{
		{
			name: "ScreamingSnakeCase",
			input: "HELLO_WORLD",
			expected: "hello_world",
		},

		{
			name: "PascalCase",
			input: "HelloWorldOutThere",
			expected: "hello_world_out_there",
		},

		{
			name: "CamelCase",
			input: "whoaThereSport",
			expected: "whoa_there_sport",
		},

		{
			name: "AnotherSnakeCase",
			input: "hello_world",
			expected: "hello_world",
		},
	}

	for _, c := range cases {
		t.Run(c.name, func(t *testing.T) {
			if v := toSnakeCase(c.input); v != c.expected {
				t.Errorf("expected '%s', got '%s'", c.expected, v)
			}
		})
	}
}

type testQuery struct {
	Name string
	PaginationDirection string
}

func TestGenerateQuery(t *testing.T) {
	cases := []struct{
		name string
		input any
		expected string
	}{
		{
			name: "BasicTestQuery",
			input: &testQuery{
				Name: "hello",
				PaginationDirection: "welp",
			},
			expected: "name=hello&pagination_direction=welp",
		},

		{
			name: "InlineStructWithScreamingSnakeCase",
			input: &struct{
				WHY_HELLO_THERE string
				THIS_IS_ACCEPTABLE int
			}{
				WHY_HELLO_THERE: "HEHEHEHE",
				THIS_IS_ACCEPTABLE: 45,
			},
			expected: "this_is_acceptable=45&why_hello_there=HEHEHEHE",
		},

		{
			name: "SomeFieldsHaveZeroValues",
			input: &struct{
				ZeroInt int
				ZeroString string
				PageParameters string
			}{
				PageParameters: "WELLWELL",
			},
			expected: "page_parameters=WELLWELL",
		},

		{
			name: "AllFieldsAreEmpty",
			input: &struct{
				ZeroInt int
				ZeroString string
				ZeroUint uint
			}{ },
			expected: "",
		},
	}

	for _, c := range cases {
		t.Run(c.name, func(t *testing.T) {
			if v := generateQueryValues(c.input); v.Encode() != c.expected {
				t.Errorf("expected '%s', got '%s'", c.expected, v.Encode())
			}
		})
	}
}
