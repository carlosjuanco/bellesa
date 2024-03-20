package main

import "fmt"

func main() {
	// slices: Son apuntadores a array, no poseen datos
	things := [7]string{"🚕", "🚗", "🚘", "🚙", "🚔", "🚨", "🎈"}
	cars := things[0:5]

	// El indice final es excluyente, debe de sumarse uno para obtener hasta
	// la posición que se desea.

	fmt.Println("Things: ", things)
	fmt.Println("Cars: ", cars)
}
