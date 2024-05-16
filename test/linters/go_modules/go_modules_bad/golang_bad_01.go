package main

import (
	"github.com/go-playground/validator/v10"
	"github.com/labstack/echo/v4"
)

if len(in) == 0 {
  return "", fmt.Errorf("Input is empty")
}

x := 0
{
  var x int
  x++
}

fmt.Println(x)
