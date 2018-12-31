# Parse each line of 1.in into an integer array
intarray = map(x -> tryparse(Int, x), readlines("1.in"))

# Question 1a
println("The resulting frequency is ", sum(intarray))

# Question 1b
let
    summ = 0             # initial sum
    resultarray = [summ] # result array holds all tallied sums

    # bootleg do-while loop
    loop = true; while loop
        for int in intarray
            summ += int
            # if a sum already appears inside resultarray, break out of the loop
            if summ in resultarray
                println("The first frequency appearing twice is ", summ)
                loop = false; break
            else
                push!(resultarray, summ)
            end
        end
    end
end
