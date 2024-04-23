package main

import "fmt"

func main() {
	fmt.Println("Una función variática")
	fmt.Println(sum(2))
	fmt.Println(sum(2, 3))
	fmt.Println(sum(2, 3, 5))
	fmt.Println(sum(2, 3, 5, 8))
	fmt.Println(sum(2, 3, 5, 8, 82, 526))

	fmt.Println("Una función variática, más limpia")
	fmt.Println(sum2(2, 5, 8, 82, 526))

	fmt.Println("Funciones anónimas")
	greet := func() {
		fmt.Println("👋 Hola")
	}

	greet()

	fmt.Println("Funciones anónimas, autoejecutarse")
	func() {
		fmt.Println("👋 Holaa")
	}()

	fmt.Println("Funciones anónimas, con parámetros")
	func(name string) {
		fmt.Println("👋 Holaa", name)
	}("gophers")
}

func sum(nums ...int) int {
	var total int
	for _, num := range nums {
		total += num
	}
	return total
}

func sum2(nums ...int) (total int) {
	for _, num := range nums {
		total += num
	}
	return
}
