package main

import (
	"fmt"
	"os"
	"os/user"
)

const G_STASH_FILE = ".gstash.db"

func Init() {
	u, err := user.Current()
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		return
	}

	if f, err := os.Stat(u.HomeDir + "/.gstash"); os.IsNotExist(err) || !f.IsDir() {
		println("Initializing...")

		os.Mkdir(u.HomeDir+"/.gstash", 0777)

		println("Done!")
	}
}
