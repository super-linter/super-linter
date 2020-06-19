#Plaintext Parameters
function BadFunction {
    param(
        [String]$Username = 'me',
        [String]$Password = 'password'
    )
    $Username
    $Password
    $VariableThatIsNotUsedLater = '5'
    try {
        'Empty Catch Block' 
    } catch {}
}

