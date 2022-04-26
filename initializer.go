package main

import (
	"fmt"
	"os"
	"os/user"
)

const G_STASH_FILE = ".gstash.db"

func Init() {
	println("Initializing...")

	u, err := user.Current()
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		return
	}
	fmt.Println(u.HomeDir)

	println("Done!")
}
