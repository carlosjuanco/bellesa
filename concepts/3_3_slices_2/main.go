package main

import "fmt"

func main() {
	// capt(): # de elementos del arreglo origen, a partir del índice donde se creó el slice.
	animals := [5]string{"🦍", "🐶", "🦮", "🐦‍⬛", "🐘"}
	pets := animals[1:3] //"🐶", "🦮"

	pets = append(pets, "🐈", "🐶", "😻")
	// Nota: Mientras no rebase la capacidad, se modifica el slice y
	//		el arreglo original

	// array[4]string{"🐶", "🦮", "🐦‍⬛", "🐘"}
	// array[8]string{"🐶", "🦮", "🐈", "🐶", "😻"}

	// ¿Cual es la razón por la que la capacidad es 8 del slice pets?
	// Cuando uno se pasa de la capacidad del arreglo origen "animals"
	// Toma de referencia la capacidad de "pets" y lo multiplica 2
	// Nota: Solo lo hace 1 vez hace la multiplicación.

	fmt.Println("Animales: ", animals)
	fmt.Println("Pets: ", pets)
	fmt.Println("Tamaño de pets: ", len(pets))
	fmt.Println("Capacidad de pets: ", cap(pets))

	// Crear un slice sin basarse en un arreglo
	pets2 := []string{"🐶", "🦮"}
	fmt.Println("Pets: ", pets2)
	fmt.Println("Tamaño de pets: ", len(pets2))
	fmt.Println("Capacidad de pets: ", cap(pets2))

	// Crear slice segunda manera
	fmt.Println("Crear slice segunda manera: ")
	pets3 := make([]string, 0, 3)
	fmt.Println("Pets: ", pets3)
	fmt.Println("Tamaño de pets: ", len(pets3))
	fmt.Println("Capacidad de pets: ", cap(pets3))
	pets3 = append(pets3, "🐈", "🐶", "😻")
	fmt.Println("Pets: ", pets3)
	fmt.Println("Tamaño de pets: ", len(pets3))
	fmt.Println("Capacidad de pets: ", cap(pets3))

	// Valor por defecto de los slices
	fmt.Printf("Valor por defecto de los slices\n")
	var pets4 []string
	fmt.Println("Pets: ", pets4)
	fmt.Println("Tamaño de pets: ", len(pets4))
	fmt.Println("Capacidad de pets: ", cap(pets4))
	// ¿Cómo validamos que un slice está vacío?
	// Ocupamos la función nil
	fmt.Printf("Validar que este vacio un slic\n")
	fmt.Println("¿Está vacío pets4: ", pets4 == nil)
}
