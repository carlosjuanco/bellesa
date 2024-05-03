package main

import (
	"flag"
	"fmt"
	"io/fs"
	"os"
)

func main() {
	//filter patter
	// flagPattern := flag.String("p", "", "filter by pattern")
	// flagAll := flag.Bool("a", false, "all files including hide files")
	// flagNumberRecords := flag.Int("n", 0, "number of records")

	//order flags
	// hasOrderByTime := flag.Bool("t", false, "sort by time, oldest first")
	// hasOrderBySize := flag.Bool("s", false, "sort by file size, smallest first")
	// hasOrderReverse := flag.Bool("r", false, "reverse order while sorting")

	flag.Parse()

	// fmt.Println("patter: ", *flagPattern)
	// fmt.Println("all: ", *flagAll)
	// fmt.Println("flagNumberRecords: ", *flagNumberRecords)
	// fmt.Println("hasOrderByTime: ", *hasOrderByTime)
	// fmt.Println("hasOrderBySize: ", *hasOrderBySize)
	// fmt.Println("hasOrderReverse: ", *hasOrderReverse)

	path := flag.Arg(0)
	if path == "" {
		path = "."
	}
	fmt.Println(path)
	dirs, err := os.ReadDir(path)
	if err != nil {
		panic(err)
	}

	fs := []file{}
	for _, v := range dirs {
		f, err := getFile(v, false)
		if err != nil {
			panic(err)
		}
		fs = append(fs, f)
	}
	fmt.Println(fs)
}

func getFile(dir fs.DirEntry, isHidden bool) (file, error) {
	info, err := dir.Info()
	if err != nil {
		return file{}, fmt.Errorf("dir.Info(): %v", err)
	}
	f := file{
		name:             dir.Name(),
		fileType:         0,
		isDir:            dir.IsDir(),
		isHidden:         isHidden,
		userName:         "j",
		groupName:        "juancho",
		size:             info.Size(),
		modificationTime: info.ModTime(),
		mode:             info.Mode().String(),
	}
	return f, nil
}
