package main

import (
	"fmt"
	"strings"
)

func main() {
	greet()
	greet2("Rojas", "Garcia")
	greet3("Rojas", "Garcia")

	name := "Juancho"
	toUpperCase(name)
	fmt.Println("Valor de name:", name)

	name2 := "Juancho"
	toUpperCase2(&name2)
	fmt.Println("Valor de name:", name2)
}

// Funsion sin parámetros
func greet() {
	fmt.Println("Hello goffer")
}

// Funsion con parámetros
func greet2(firstName string, lastName string) {
	fmt.Println("Hello", firstName, lastName)
}

// Algo nuevo en funciones
// Podemos omitir el tipo de datos en los primeros parámetros
// si son del mismo tipo los siguientes parámetros
func greet3(firstName, lastName string) {
	fmt.Println("Hello", firstName, lastName)
}

// Enviar parámetros sin referencia
func toUpperCase(text string) {
	text = strings.ToUpper(text)
}

// Enviar parámetros por referencia
func toUpperCase2(text *string) {
	*text = strings.ToUpper(*text)
}
