package main

import (
	"fmt"
	"os"
)

func main() {
	fmt.Println("Diferir una línea")
	// defer fmt.Println(3)
	// fmt.Println(1)
	// fmt.Println(2)

	fmt.Println("Diferir tres línea")
	// Cuando se difiere más de una línea, se va guardando en una pila
	// al momento de ejecutarlo, ejecuta primero el último que se guardó
	// hasta el primero que se almacenó
	// defer fmt.Println(3)
	// defer fmt.Println(2)
	// defer fmt.Println(1)

	fmt.Println("Otra manera de ver la función diferida")
	// num := 4
	// defer fmt.Println("Número", num)

	// num = 10
	// fmt.Println("Número", num)

	fmt.Println("En la práctica")
	// Me sirve para limpiar recursos, cerrar archivos, cerrar conexión de red
	// o cerrar controladores de bases de datos.

	fmt.Println("Un ejemplo con un archivo")
	// Hay dos líneas que cierran el archivo, el primero en caso que ocurra un
	// error al momento de escribir sobre el archivo, el segundo si todo sale
	// bien al escribir en el archivo, nos aseguramos de cerrar el archivo.
	// Aquí es donde nos sirve defer, ya que lo ponemos, después de crear el
	// archivo, esto hará, que cuando ocurran los dos casos, siempre se cierre
	// el archivo.
	file, err := os.Create("text.txt")
	if err != nil {
		fmt.Println(err)
		return
	}

	defer file.Close()

	_, err = file.Write([]byte("Hello juancho"))
	if err != nil {
		// file.Close()
		fmt.Println(err)
		return
	}

	// file.Close()
}
