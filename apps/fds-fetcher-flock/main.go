package main

import (
	"log"
	"os"

	"fds-flock-of-fetchers/cmd"
)

func main() {
	log.SetFlags(0)
	if err := cmd.Execute(); err != nil {
		log.Fatalf("Error: %s", err)
		os.Exit(1)
	}
}
