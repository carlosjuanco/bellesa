package main

import "fmt"

func main() {
	// Primera manera de crear un arreglo
	var flags [3]string
	flags[0] = "🇲🇽"
	flags[1] = "🇺🇾"
	flags[2] = "🇨🇴"
	fmt.Println(flags)

	// Segunda manera de crear un arreglo
	flags2 := [3]string{"🇲🇽", "🇺🇾", "🇨🇴"}
	fmt.Println(flags2)

	// Nota: En Go no se puede aumentar el tamaño de un arreglo
	//		debido a que se define el tamaño desde un principio

	// Tercera manera de crear un arreglo
	flags3 := [...]string{"🇲🇽", "🇺🇾", "🇨🇴", "🇨🇴"}
	fmt.Println(flags3)
}
