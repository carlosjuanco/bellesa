package main

import (
	"flag"
	"fmt"
)

func main() {
	//filter patter
	flagPattern := flag.String("p", "", "filter by pattern")
	flagAll := flag.Bool("a", false, "all files including hide files")
	flagNumberRecords := flag.Int("n", 0, "number of records")

	//order flags
	hasOrderByTime := flag.Bool("t", false, "sort by time, oldest first")
	hasOrderBySize := flag.Bool("s", false, "sort by file size, smallest first")
	hasOrderReverse := flag.Bool("r", false, "reverse order while sorting")

	flag.Parse()
	fmt.Println("patter: ", *flagPattern)
	fmt.Println("all: ", *flagAll)
	fmt.Println("flagNumberRecords: ", *flagNumberRecords)
	fmt.Println("hasOrderByTime: ", *hasOrderByTime)
	fmt.Println("hasOrderBySize: ", *hasOrderBySize)
	fmt.Println("hasOrderReverse: ", *hasOrderReverse)
}
