package main

import "fmt"

func main() {
	// slices: Son apuntadores a array, no poseen datos
	things := [7]string{"🚕", "🚗", "🚘", "🚙", "🚔", "🚨", "🎈"}
	cars := things[0:5] // "🚕", "🚗", "🚘", "🚙", "🚔"
	red := things[5:7]  // "🚨", "🎈"

	// El indice final es "Excluyente", debe de sumarse uno para obtener hasta
	// la posición que se desea.

	fmt.Println("Things: ", things)
	fmt.Println("Cars: ", cars)
	fmt.Println("Red: ", red)
	fmt.Println("Cars[0]: ", cars[0])
	fmt.Println("Red[0]: ", red[0])

	//Modificar
	red[1] = "🚑"
	fmt.Println("Red[1]", red[1])
	fmt.Println("Things: ", things)
	fmt.Println("Cars: ", cars)
	fmt.Println("Red: ", red)
	fmt.Println("Cars[0]: ", cars[0])
}
