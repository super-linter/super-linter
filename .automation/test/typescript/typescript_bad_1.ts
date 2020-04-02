const spiderman = (person: String) => {
    return 'Hello, ' + person;
}

var handler = createHandler( { path : /webhook, secret : (process.env.SECRET) })

let user = 1;
console.log(spiderman(user));
