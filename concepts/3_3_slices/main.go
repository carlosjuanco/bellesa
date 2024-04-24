package main

import "fmt"

func main() {
	// slices: Son apuntadores a array, no poseen datos
	things := [7]string{"🚕", "🚗", "🚘", "🚙", "🚔", "🚨", "🎈"}
	cars := things[0:5] // "🚕", "🚗", "🚘", "🚙", "🚔"
	red := things[4:7]  // "🚔", "🚨", "🎈"

	// El indice final es "Excluyente", debe de sumarse uno para obtener hasta
	// la posición que se desea.

	fmt.Println("Things: ", things)
	fmt.Println("Cars: ", cars)
	fmt.Println("Red: ", red)
	fmt.Println("Cars[0]: ", cars[0])
	fmt.Println("Red[0]: ", red[0])

	//Modificar
	red[0] = "🚑" //Al modificar el índice 0, se modifican el arreglo cars
	// y things
	fmt.Println("Red[1]", red[1])
	fmt.Println("Things: ", things)
	fmt.Println("Cars: ", cars)
	fmt.Println("Red: ", red)
	fmt.Println("Cars[0]: ", cars[0])

	fmt.Println("Se puede no especificar el índice inicial, obtendriamos el mismo resultado\n")
	cars2 := things[:5] // "🚕", "🚗", "🚘", "🚙", "🚔"
	fmt.Println("Cars: ", cars2)

	fmt.Println("Se puede no especificar el índice final, obtendriamos el mismo resultado\n")
	red2 := things[4:] // "🚨", "🎈"
	fmt.Println("Red: ", red2)

	fmt.Println("Se puede no especificar el índice inicial y final, obtendremos el arreglo original\n")
	all := things[:]
	fmt.Println("Todos: ", all)
}
