package main

import "fmt"

func main() {
	// bool
	var a bool = true
	fmt.Printf("Tipo: %T, Valor: %v\n", a, a)
	
	// string
	var b string = "juancho"
	fmt.Printf("Tipo: %T, Valor: %v\n", b, b)

	// numérico

	/*
		`uint`
    	* uint8  unsigned 8-bit  integers (0 to 255)
    	* uint16 unsigned 16-bit integers (0 to 65535)
    	* uint32 unsigned 32-bit integers (0 to 4294967295)
    	* uint64 unsigned 64-bit integers (0 to 18446744073709551615)


    	`uint`
   	 * int8  signed 8-bit  integers (-128 to 127)
    	* int16 signed 16-bit integers (-32768 to 32767)
    	* int32 signed 32-bit integers (-2147483648 to 2147483647)
    	* int64 signed 64-bit integers (-9223372036854775808 to 9223372036854775807)


    	`byte` // alias for uint8


    	`rune` // alias for int32
           // represents a Unicode code point


    	`float32` `float64`
	*/

	// Restricciones entre tipos de datos numéricos
	// No se pueden hacer operaciones entre los diferentes tipos de datos enteros 
	// y con punto flotante.
	var aa uint8 = 200
	var bb uint16 = 800


	// c := aa + bb
	// fmt.Printf("Tipo: %T, Valor: %v", c, c)
	// output
	// invalid operation: aa + bb (mismatched types uint8 and uint16

	c := uint16(aa) + bb
	fmt.Printf("Tipo: %T, Valor: %v\n", c, c)

	// El identificador blan
	var d uint8 = 200
	var e uint16 = 800

	_ = uint16(d) + e

	fmt.Printf("Tipo: %T, Valor: %v\n", d, d)

	fmt.Printf("Valor por defecto de los tipo de datos\n")
	fmt.Printf("Bool\n")
	var g bool
	fmt.Printf("Tipo: %T, Valor: %v\n", g, g)
	
	fmt.Printf("string\n")
	var h string
	fmt.Printf("Tipo: %T, Valor: %v\n", h, h)
	
	fmt.Printf("Numérico\n")
	var i uint8
	fmt.Printf("Tipo: %T, Valor: %v\n", i, i)
}