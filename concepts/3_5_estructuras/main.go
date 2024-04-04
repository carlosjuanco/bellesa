package main

import "fmt"

// Declaración de una estructura
type Person struct {
	Name        string
	Age         uint8
	HasChildren bool
}

func main() {

	fmt.Println("Uso de una estructura con nombre de propiedades")
	alexys := Person{
		Name:        "Alexys",
		Age:         42,
		HasChildren: false,
	}

	fmt.Printf("%+v\n", alexys)

	fmt.Println("Uso de una estructura sin indicar el nombre de las propiedades")
	beto := Person{"Beto", 33, true}
	fmt.Printf("%+v\n", beto)

	fmt.Println("Uso de una estructura indicando una sola propiedad")
	fmt.Println("La estructura Person tiene 3 propiedades")
	alejo := Person{Age: 32}
	fmt.Printf("%+v\n", alejo)

	fmt.Println("Vamos a acceder a una propiedad en especifico de las estructura persona")
	fmt.Printf("%+v\n", alexys.Name)
	fmt.Printf("%+v\n", beto.HasChildren)
	fmt.Printf("%+v\n", alejo.Age)

	fmt.Println("Crear un apuntador para la estructura alexys")
	alvaro := &alexys
	fmt.Printf("%+v\n", alvaro)
	fmt.Printf("%+v\n", alexys)

	fmt.Println("Modificaremos datos de la variable alexys desde el apuntador alvaro")
	fmt.Println("Para hacerlo utilizamos el operador de referenciacion")
	(*alvaro).Age = 50
	fmt.Printf("%+v\n", alexys)
	fmt.Printf("%+v\n", alvaro)

	fmt.Println("Ahora lo realizaremos sin usar el operador de referenciacion")
	(*alvaro).Age = 60
	fmt.Printf("%+v\n", alexys)
	fmt.Printf("%+v\n", alvaro)

}
fmt.Println("Uso de una estructura con nombre de propiedades")
alexys := Person{
	Name:        "Alexys",
	Age:         42,
	HasChildren: false,
}

fmt.Printf("%+v\n", alexys)

fmt.Println("Uso de una estructura sin indicar el nombre de las propiedades")
beto := Person{"Beto", 33, true}
fmt.Printf("%+v\n", beto)

fmt.Println("Uso de una estructura indicando una sola propiedad")
fmt.Println("La estructura Person tiene 3 propiedades")
alejo := Person{Age: 32}
fmt.Printf("%+v\n", alejo)

fmt.Println("Vamos a acceder a una propiedad en específico de las estructura persona")
fmt.Printf("%+v\n", alexys.Name)
fmt.Printf("%+v\n", beto.HasChildren)
fmt.Printf("%+v\n", alejo.Age)

fmt.Println("Crear un apuntador para la estructura alexys")
alvaro := &alexys
fmt.Printf("%+v\n", alvaro)
fmt.Printf("%+v\n", alexys)

fmt.Println("Modificaremos datos de la variable alexys desde el apuntador alvaro")
fmt.Println("Para hacerlo utilizamos el operador de referenciación")
(*alvaro).Age = 50
fmt.Printf("%+v\n", alexys)
fmt.Printf("%+v\n", alvaro)

fmt.Println("Ahora lo realizaremos sin usar el operador de referenciación")
(*alvaro).Age = 60
fmt.Printf("%+v\n", alexys)
fmt.Printf("%+v\n", alvaro)
