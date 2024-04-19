package main

import "fmt"

func main() {
	fmt.Println("Clásico y sin paréntesis")
	for i := 0; i <= 5; i++ {
		fmt.Println(i)
	}

	fmt.Println("Continuo")
	i := 0
	for i <= 5 {
		fmt.Println(i)
		i++
	}

	fmt.Println("Por siempre")
	fmt.Println("Este tipo de for, puede servir para estar escuchando constantemente y después realizar algo.")
	i = 0
	for {
		if i == 24456 {
			break
		}

		fmt.Println(i)
		i++
	}

	fmt.Println("Para recorrer un slice")
	food := []string{"pizza", "lentes", "disco", "credenciales"}

	for index, valor := range food {
		fmt.Println("Indice: ", index, "Valor: ", valor)
	}

	fmt.Println("Para recorrer un slice directo")

	for index, valor := range []string{"pizza", "lentes", "disco", "credenciales"} {
		fmt.Println("Indice: ", index, "Valor: ", valor)
	}

	fmt.Println("Modificar un slice sin el índice")
	numbers := []uint8{2, 4, 6, 8}

	for _, valor := range numbers {
		valor *= 2
	}
	fmt.Println(numbers)
	fmt.Println("No modifica ningun valor del slice")

	fmt.Println("Modificar un slice con el índice")
	number := []uint8{2, 4, 6, 8}

	for index := range number {
		number[index] *= 2
	}
	fmt.Println(number)
	fmt.Println("Si modifico los valores del slice")

	fmt.Println("Recorrer un mapa")
	food2 := map[string]string{
		"pizza":      "🍕",
		"hamburgesa": "🍔",
		"apple":      "🍎",
		"hotdog":     "🌭",
	}

	for index, valor := range food2 {
		fmt.Println("Índice: ", index, "Valor: ", valor)
	}

	fmt.Println("Recorrer un texto sin hacerle el casting")

	for index, valor := range "Juan Carlos" {
		fmt.Println("Índice: ", index, "Valor: ", valor)
	}

	fmt.Println("Recorrer un texto haciendo el casting")

	for index, valor := range "Juan Carlos" {
		fmt.Println("Índice: ", index, "Valor: ", string(valor))
	}
}
