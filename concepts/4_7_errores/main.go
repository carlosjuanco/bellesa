package main

import (
	"errors"
	"fmt"
	"strconv"
)

var errNotFound = errors.New("Not found")

func main() {
	fmt.Println("Cachar un error de una función que ya existe")
	num, err := strconv.Atoi("1")
	if err != nil {
		fmt.Println(err)
		return
	}
	fmt.Println(num)

	fmt.Println("Crear nuevos errores")
	num2, err2 := search("a")
	if err2 != nil {
		fmt.Println(err2)
		return
	}
	fmt.Println(num2)
}

func search(key string) (string, error) {
	return "", errNotFound
}
