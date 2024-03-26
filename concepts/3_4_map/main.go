package main

import "fmt"

func main() {
	fmt.Println("Primera forma de crear un mapa")
	fmt.Println("Primero declara y posteriormente asigna valores")
	music := make(map[string]string)
	music["guitar"] = "🎸"
	music["violin"] = "🎻"

	fmt.Println(music)

	fmt.Println("Segunda forma de crear un mapa")
	fmt.Println("Crea el mapa y asigna valores")
	tech := map[string]string{
		"computer": "💻",
		"mouse":    "🖱️",
	}

	fmt.Println(tech)

	fmt.Println("Eliminar un elemento de un mapa")
	delete(tech, "computer")
	fmt.Println(tech)

	fmt.Println("Acceder a un elemento de un mapa")
	fmt.Println(music["guitar"])

	fmt.Println("Acceder a un elemento de un mapa que no existe")
	fmt.Println(music["fake"])
	fmt.Println("Devuelve un valor vacío, de acuerdo al valor por defecto del tipo de dato")

	fmt.Println("¿Cómo puedo saber si una llave de un mapa existe?")
	valor, existe := music["fake"]
	fmt.Println(valor, existe)
}
