package main

import (
	"github.com/go-playground/validator/v10"
	"github.com/labstack/echo/v4"
)

type FooType struct {
	Var *string `validate:"alphanum"`
}

func post(echo.Context) (err error) {
	validate := validator.New()

	if err = validate.Struct(FooType{Var: nil}); err != nil {
		return
	}

	return
}

func server() (e *echo.Echo) {
	e = echo.New()
	e.POST("/", post)
	return
}

func main() {
	e := server()
	e.Logger.Fatal(e.Start(":8000"))
}
