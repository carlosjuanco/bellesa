package main

import "fmt"

func main() {
	// Operadores aritméticos (), *, /, %, +, -
	var a int8 = 2 + 3
	fmt.Println(a)

	var b int8 = 2 + 3 * 2
	fmt.Println(b)

	var c int8 = (2 + 3) * 2
	fmt.Println(c)

	// Operadores de asignación =, +=, -=, *=, /=, %=

	var d int = 5
	d = d + 2
	fmt.Println(d)

	var e int = 5
	e += 2
	fmt.Println(e)

	var f int = 5
	f -= 2
	fmt.Println(f)

	// Declaración post-incremento y post-decremento: ++ y --
	// (No son una expresión sino una declaración)
	var g int = 6
	g++
	fmt.Println(g)

	var h int = 6
	h--
	fmt.Println(h)
}