package main

import "fmt"

func main() {
	// Operadores de comparación: >, <, ==, !=, >= y <=
	fmt.Println(4 > 6)
	fmt.Println(4 < 6)
	fmt.Println(4 == 4)
	fmt.Println(4 != 5)
	fmt.Println(4 >= 4)
	fmt.Println(5 >= 4)
	fmt.Println(4 <= 4)
	fmt.Println(3 <= 4)

	// Operadores lógicos: && y ||
	var age uint = 61
	fmt.Println("¿Es adulto? ", age >= 18 && age <= 60)
	fmt.Println("¿Es niño o anciano? ", age < 18 || age > 60)

	// Operador lógico unirio: !
	fmt.Println(!(4 == 4))
	fmt.Println(!(4 != 4))
}