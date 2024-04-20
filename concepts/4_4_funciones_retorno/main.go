package main

import (
	"fmt"
	"strings"
)

func main() {
	fmt.Println("Retornar dos resultados en una función")
	lower, upper := convert("EDteam")
	fmt.Println("Minúsculas:", lower, "Mayúsculas:", upper)

	fmt.Println("Otra manera de retornar dos resultados en una función")

	lower2, upper2 := convert2("EDteam")
	fmt.Println("Minúsculas:", lower2, "Mayúsculas:", upper2)
}

func convert(text string) (string, string) {
	lower := strings.ToLower(text)
	upper := strings.ToUpper(text)

	return lower, upper
}

func convert2(text string) (lower string, upper string) {
	lower = strings.ToLower(text)
	upper = strings.ToUpper(text)

	return
}
