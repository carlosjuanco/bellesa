package main

import "fmt"

func main() {
	fmt.Println("Funciones que reciben funciones")
	nums := []int{2, 4, 23, 36, 47, 55, 66, 66, 77, 88, 99}
	result := filter(nums, func(num int) bool { return num < 5 })
	fmt.Println(result)
}

func filter(nums []int, callback func(int) bool) []int {
	result := make([]int, 0, len(nums))
	for _, num := range nums {
		if callback(num) {
			result = append(result, num)
		}
	}
	return result
}
