package main

import (
	"errors"
	"fmt"
	"strconv"
)

var errNotFound = errors.New("Not found")
var food = map[int]string{
	1: "🍕",
	2: "🍔",
}

func main() {
	fmt.Println("Cachar un error de una función que ya existe")
	num, err := strconv.Atoi("1")
	if err != nil {
		fmt.Println(err)
		return
	}
	fmt.Println(num)

	fmt.Println("Crear nuevos errores")
	// num2, err2 := search("1")
	// if err2 != nil {
	// 	fmt.Println(err2)
	// 	return
	// }
	// fmt.Println(num2)

	fmt.Println("Administrar los errores")
	num2, err3 := search2("1")
	if err3 != nil {
		fmt.Println(err3)
		return
	}
	fmt.Println(num2)

	fmt.Println("Administrar los errores, haciendo un historial")
	num2, err4 := search3("2")
	if err4 != nil {
		fmt.Println("search3()", err4)
		return
	}
	fmt.Println(num2)

	fmt.Println("Administrar los errores, haciendo un historial y formateando con %w")
	num2, err5 := search4("3")
	if errors.Is(err5, errNotFound) {
		fmt.Println("Pudimos controlador un error")
	}
	if err5 != nil {
		fmt.Println("search3()", err5)
		return
	}
	fmt.Println(num2)
}

func search(key string) (string, error) {
	return "", errNotFound
}

func search2(key string) (string, error) {
	num, err := strconv.Atoi(key)
	if err != nil {
		return "", err
	}
	emoji, err := findFood(num)
	if err != nil {
		return "", err
	}
	return emoji, nil
}

func findFood(id int) (string, error) {
	value, ok := food[id]
	if !ok {
		return "", errNotFound
	}
	return value, nil
}

func search3(key string) (string, error) {
	num, err := strconv.Atoi(key)
	if err != nil {
		return "", fmt.Errorf("strconv.Atoi(): %v", err)
	}
	emoji, err := findFood2(num)
	if err != nil {
		return "", fmt.Errorf("findFood(): %v", err)
	}
	return emoji, nil
}

func findFood2(id int) (string, error) {
	value, ok := food[id]
	if !ok {
		return "", errNotFound
	}
	return value, nil
}

func search4(key string) (string, error) {
	num, err := strconv.Atoi(key)
	if err != nil {
		return "", fmt.Errorf("strconv.Atoi(): %w", err)
	}
	emoji, err := findFood3(num)
	if err != nil {
		return "", fmt.Errorf("findFood(): %w", err)
	}
	return emoji, nil
}

func findFood3(id int) (string, error) {
	value, ok := food[id]
	if !ok {
		return "", errNotFound
	}
	return value, nil
}
