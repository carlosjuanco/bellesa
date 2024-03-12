package main

import "fmt"

func main() {
	var apple string
	var banana string
	var orange string

	apple = "🦊"
	banana = "🍌"
	orange = "🍊"

	fmt.Println(apple, banana, orange)

	var manzana string = "🦊"
	var platano string = "🍌"
	var naranja string = "🍊"

	fmt.Println(manzana, platano, naranja)

	var (
		tejocote string = "🦊"
		pera     string = "🍌"
		pitana   string = "🍊"
	)

	fmt.Println(tejocote, pera, pitana)

	var fresa, pina, durazno string = "🦊", "🍌", "🍊"

	fmt.Println(fresa, pina, durazno)

	silla, meza, flor := "🦊", "🍌", "🍊"
	silla, sol := "silla", "🌞"

	fmt.Println(silla, meza, flor, sol)

	fmt.Println(1, "彼氏彼女の事情", nil)

}
