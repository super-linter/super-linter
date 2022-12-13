enum Test {
  Hoo = 'hoo'
}

const spiderman = (person: string): string => {
  return `Hello, ${person}`
}

const user = 'Peter Parker'
console.log(spiderman(user))
console.log(Test.Hoo)
