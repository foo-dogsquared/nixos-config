package pexels

import (
	"math"
)

type Pagination struct {
	Page int `json:"page"`
	PerPage int `json:"per_page"`
	Total int `json:"total_results"`
	URL string `json:"url,omitempty"`

	PrevPage string `json:"prev_page,omitempty"`
	NextPage string `json:"next_page,omitempty"`

	Photos []*Photo `json:"photos,omitempty"`
	Videos []*Video `json:"videos,omitempty"`
}

// Common pagination-related parameters.
type PageParameters struct {
	// The actual page you're requesting.
	Page int `schema:"page,default:1"`

	// The number of items per-page.
	PerPage int `schema:"per_page,default:15"`
}

type PhotoPageParams PageParameters

type VideoPageParams struct {
	Page int `schema:"page,default:1"`
	PerPage int `schema:"per_page,default:5"`
	MinWidth int `schema:"min_width"`
	MaxWidth int `schema:"max_width"`
	MinHeight int `schema:"min_height"`
	MinDuration int `schema:"min_duration"`
	MaxDuration int `schema:"max_duration"`
}

type PaginationDirection string
const (
	PaginationNext PaginationDirection = "next"
	PaginationPrev PaginationDirection = "prev"
)

func (page *Pagination) Paginate(dir PaginationDirection) string {
	switch dir {
	case PaginationNext:
		return page.NextPage
	case PaginationPrev:
		return page.PrevPage
	}

	return ""
}

// Return the number of pages needed for the Pexels API pagination. This does
// not keep the imposed limitation of having a maximum number of 80 items per
// page.
func numberOfPaginations(total, perPage uint) uint {
	x := float64(total / perPage)
	return uint(math.Floor(x) + 1)
}
