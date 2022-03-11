enum Test {
  Hoo = 'hoo'
}

const spiderman = (person) => {
  return 'Hello, ' + person
}

const user = 'Peter Parker'
console.log(spiderman(user))
console.log(Test.Hoo)
