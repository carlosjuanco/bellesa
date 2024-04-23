package main

import "fmt"

func main() {
	fmt.Println("Funciones que reciben una función")
	nums := []int{2, 4, 23, 36, 47, 19, 66, 66, 17, 88, 99}
	result := filter(nums, func(num int) bool { return num < 5 })
	fmt.Println(result)

	fmt.Println("Funciones que reciben una función, más limpio")
	result = filter(nums, greatherToTen)
	fmt.Println(result)

	fmt.Println("Funciones que reciben una función, más limpio")
	result = filter(nums, lessThanTwenty)
	fmt.Println(result)

	fmt.Println("Implementación de una función que retorna otra función")
	resultado := sum(3)(3)
	fmt.Println(resultado)

	fmt.Println("Ventajas")
	plus10 := sum(10)

	fmt.Println(plus10(0))
	fmt.Println(plus10(2))
	fmt.Println(plus10(4))
	fmt.Println(plus10(6))
	fmt.Println(plus10(8))
}

func greatherToTen(num int) bool {
	return num < 5
}

func lessThanTwenty(num int) bool {
	return num < 20
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

func sum(a int) func(int) int {
	return func(b int) int {
		return a + b
	}
}
