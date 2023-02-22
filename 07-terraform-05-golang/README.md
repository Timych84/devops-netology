# Домашнее задание к занятию "5. Основы golang"

С `golang` в рамках курса, мы будем работать не много, поэтому можно использовать любой IDE.
Но рекомендуем ознакомиться с [GoLand](https://www.jetbrains.com/ru-ru/go/).

## Задача 1. Установите golang.
1. Воспользуйтесь инструкций с официального сайта: [https://golang.org/](https://golang.org/).
2. Так же для тестирования кода можно использовать песочницу: [https://play.golang.org/](https://play.golang.org/).

## Задача 2. Знакомство с gotour.
У Golang есть обучающая интерактивная консоль [https://tour.golang.org/](https://tour.golang.org/).
Рекомендуется изучить максимальное количество примеров. В консоли уже написан необходимый код,
осталось только с ним ознакомиться и поэкспериментировать как написано в инструкции в левой части экрана.

## Задача 3. Написание кода.
Цель этого задания закрепить знания о базовом синтаксисе языка. Можно использовать редактор кода
на своем компьютере, либо использовать песочницу: [https://play.golang.org/](https://play.golang.org/).

1. Напишите программу для перевода метров в футы (1 фут = 0.3048 метр). Можно запросить исходные данные
у пользователя, а можно статически задать в коде.
    Для взаимодействия с пользователем можно использовать функцию `Scanf`:
    ```
    package main

    import "fmt"

    func main() {
        fmt.Print("Enter a number: ")
        var input float64
        fmt.Scanf("%f", &input)

        output := input * 2

        fmt.Println(output)
    }
    ```


```go
package main

import "fmt"

func main() {
	fmt.Print("Enter meters: ")
	var input float64
	fmt.Scanf("%f", &input)
	result := convertMeters(input)
	fmt.Println(result)
}

func convertMeters(m float64) float64 {
	var input float64
	fmt.Scanf("%f", &input)
	output := m / 0.3048
	return output
}
```


1. Напишите программу, которая найдет наименьший элемент в любом заданном списке, например:
    ```
    x := []int{48,96,86,68,57,82,63,70,37,34,83,27,19,97,9,17,}
    ```


```go
package main

import (
	"fmt"
)

func main() {
	x := []int{48, 96, 86, 68, 57, 82, 63, 70, 37, 34, 83, 27, 19, 97, 9, 17, 10}
	result := findMinvalue(x)
	fmt.Printf("Minimum value is: %d", result)
}

func findMinvalue(sl []int) int {
	minVal := sl[0]
	fmt.Printf("Find minimum value in %v\n", sl)
	for i := range sl {
		if sl[i] < minVal {
			minVal = sl[i]
		}
	}
	return minVal
}
```



1. Напишите программу, которая выводит числа от 1 до 100, которые делятся на 3. То есть `(3, 6, 9, …)`.



```go
package main

import (
	"fmt"
)

func main() {
	minVal := 0
	maxVal := 100
	resultNumbers := findThreeRemainder(minVal, maxVal)
	fmt.Println(resultNumbers)
}

func findThreeRemainder(min, max int) []int {
	var resultNumbers []int
	for i := min; i <= max; i++ {
		if i%3 == 0 {
			resultNumbers = append(resultNumbers, i)
		}
	}
	return resultNumbers
}
```


В виде решения ссылку на код или сам код.

## Задача 4. Протестировать код (не обязательно).

Создайте тесты для функций из предыдущего задания.


### Задача 1

```go
package main

import (
	"testing"
)

func TestConvertMeters(t *testing.T) {
	var tests = []struct {
		meters float64
		foots  float64
	}{
		{10, 32.808398950131235},
		{1, 3.280839895013123},
	}
	for _, tt := range tests {
		result := convertMeters(tt.meters)
		if result != tt.foots {
			t.Errorf("Result: %f is not %f", result, tt.foots)
		}
	}
}
```

### Задача 2


```go
package main

import "testing"

func TestFindMinvalue(t *testing.T) {
	var tests = []struct {
		numbers []int
		result  int
	}{
		{[]int{48, 96, 86, 68, 57, 82, 63, 70, 37, 34, 83, 27, 19, 97, 9, 17, 10}, 9},
		{[]int{1, 2, 3}, 1},
	}
	for _, tt := range tests {
		x := tt.numbers
		result := findMinvalue(x)
		if result != tt.result {
			t.Errorf("Result: %d is not %d", result, tt.result)
		}
	}
}
```


### Задача 3


```go
package main

import (
	"fmt"
	"reflect"
	"testing"
)

func TestFindThreeRemainder(t *testing.T) {
	var tests = []struct {
		min    int
		max    int
		result []int
	}{
		{0, 100, []int{0, 3, 6, 9, 12, 15, 18, 21, 24, 27, 30, 33, 36, 39, 42, 45, 48, 51, 54, 57, 60, 63, 66, 69, 72, 75, 78, 81, 84, 87, 90, 93, 96, 99}},
		{0, 10, []int{0, 3, 6, 9}},
	}
	for _, tt := range tests {
		result := findThreeRemainder(tt.min, tt.max)
		fmt.Println(result)
		if !reflect.DeepEqual(result, tt.result) {
			t.Errorf("Result: %d is not %d", result, tt.result)
		}
	}
}
```

---

### Как cдавать задание

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
