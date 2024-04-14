package main

import "fmt"

func main() {
	fmt.Println("if")
	character := "🦸🏽"

	if character == "🦸🏽" {
		fmt.Println("Es un superheroe")
	} else if character == "🦹🏼" {
		fmt.Println("Es un supervillano")
	} else {
		fmt.Println("Es un personaje normal")
	}

	fmt.Println("Que la variable no este al alcance después del if")
	if personaje := "🦹🏼"; personaje == "🦸🏽" {
		fmt.Println("Es un superheroe")
	} else if personaje == "🦹🏼" {
		fmt.Println("Es un supervillano")
	} else {
		fmt.Println("Es un personaje normal")
	}

	fmt.Println("Switch")
	person := "💻"
	switch person {
	case "🦸🏽":
		fmt.Println("Es un superheroe")
	case "🦹🏼":
		fmt.Println("Es un supervillano")
	default:
		fmt.Println("Es un personaje normal")
	}

	fmt.Println("Lo nuevo de Switch")
	perso := "🙅"
	switch perso {
	case "🦸🏽", "🧞":
		fmt.Println("Es un superheroe")
	case "🦹🏼", "🙅":
		fmt.Println("Es un supervillano")
	default:
		fmt.Println("Es un personaje normal")
	}
	fmt.Println("Lo segundo nuevo de Switch")
	fmt.Println("La ventaja, es que podemos ocupar diferentes operadores lógicos.")
	personaa := "🙅"
	switch {
	case personaa == "🦸🏽" || personaa == "🧞":
		fmt.Println("Es un superheroe")
	case personaa == "🦹🏼" || personaa == "🙅":
		fmt.Println("Es un supervillano")
	default:
		fmt.Println("Es un personaje normal")
	}
	fmt.Println("La tercera cosa nueva de Switch")
	fmt.Println("La ventaja, podemos evaluar otra variable.")
	per := "🙅"
	canSearch := false
	switch {
	case !canSearch:
		fmt.Println("No esta permitida la busqueda")
	case per == "🦸🏽" || per == "🧞":
		fmt.Println("Es un superheroe")
	case per == "🦹🏼" || per == "🙅":
		fmt.Println("Es un supervillano")
	default:
		fmt.Println("Es un personaje normal")
	}
}
