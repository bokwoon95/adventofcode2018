module Hello
export foo
function foo()
    println("yeetus deletus")
end
end

function main()
    Hello.foo()
end

isinteractive() || main()
