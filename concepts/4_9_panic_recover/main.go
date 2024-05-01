package main

import "fmt"

func main() {
	fmt.Println("Mostrar un pánico")
	// division(100, 10)
	// division(200, 25)
	// division(200, 0)
	// division(34, 8)

	fmt.Println("Recuperarnos de un pánico")
	division2(100, 10)
	division2(200, 25)
	division2(200, 0)
	division2(34, 8)
}

func division(dividend, divisor int) {
	validateZero(divisor)
	fmt.Println(dividend / divisor)
}

func validateZero(divisor int) {
	if divisor == 0 {
		panic("😊No puedes dividir por cero")
	}
}

func division2(dividend, divisor int) {
	defer func() {
		if r := recover(); r != nil {
			fmt.Println("Me recupere del pánico")
		}
	}()
	validateZero2(divisor)
	fmt.Println(dividend / divisor)
}

func validateZero2(divisor int) {
	if divisor == 0 {
		panic("😊No puedes dividir por cero")
	}
}
