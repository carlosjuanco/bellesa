package main

import "fmt"

func main() {
	// Crear una constante
	const os string = "linux"
	fmt.Println(os)

	// Crear constante en bloque
	const (
	    lapicera = "Lapicera"
	    flor     = "Flor"
	)
	fmt.Println(lapicera, flor)

	// Crear múltiples constantes y asignarles su valor
	const radio, tool string = "Radio", "Herramientas"
	fmt.Println(radio, tool)

	// Ocupar iota para incrementar el valor a las constantes
	const (
	    jan = iota + 1
	    feb
	    mar
	    abri
	    may
	    jun
	)
	fmt.Println(jun)
}