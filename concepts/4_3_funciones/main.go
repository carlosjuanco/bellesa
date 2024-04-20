package main

import (
	"fmt"
	"strings"
)

func main() {
	greet()
	greet2("Rojas", "Garcia")
	greet3("Rojas", "Garcia")

	fmt.Println("Retorno de valor:", toUpperCase("juancho and Adriana"))

	name := "Juancho"
	toUpperCase2(name)
	fmt.Println("Valor de name:", name)

	name2 := "Juancho"
	toUpperCase3(&name2)
	fmt.Println("Valor de name:", name2)
}

// Función sin parámetros
func greet() {
	fmt.Println("Hello goffer")
}

// Función con parámetros
func greet2(firstName string, lastName string) {
	fmt.Println("Hello", firstName, lastName)
}

// Algo nuevo en funciones
// Podemos omitir el tipo de datos en los primeros parámetros
// si son del mismo tipo los siguientes parámetros
func greet3(firstName, lastName string) {
	fmt.Println("Hello", firstName, lastName)
}

// Enviar parámetros sin referencia y retornando un valor
func toUpperCase(text string) string {
	text = strings.ToUpper(text)
	return text
}

// Enviar parámetros sin referencia sin retornar nada
func toUpperCase2(text string) {
	text = strings.ToUpper(text)
}

// Enviar parámetros por referencia
func toUpperCase3(text *string) {
	*text = strings.ToUpper(*text)
}
