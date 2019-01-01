strarray = readlines("3.in")

# Question 3a
function claimer(arr::Array{Union{Int,Char}}, id::Int, (r, c)::Tuple{Int,Int}, (h, w)::Tuple{Int,Int})
    """
    Stakes a claim denoted by r,c,h,w on the array
    Note: 0 means an unclaimed cell, otherwise it is claimed
    For each affected cell, if it is unclaimed it becomes claimed by the id
    If it is already claimed it becomes an 'x' instead
    """
    for i in r+1:r+h
        for j in c+1:c+w
            arr[i,j] = arr[i,j] == 0 ? id : 'x'
        end
    end
end

# Create a 1000 by 1000 array of zeros
checkerboard = convert(Array{Union{Int,Char}}, zeros(Int, 1000, 1000))

# Loop through each claim in 3.in and extract the id, row, column, height & width
# For each claim, pass it through the claimer() function
for str in strarray
    regexresult = match(r"#(?<id>-?\d+) @ (?<column>\d+),(?<row>\d+): (?<width>\d+)x(?<height>\d+)", str)
    id     = tryparse(Int, regexresult[:id])
    row    = tryparse(Int, regexresult[:row])
    column = tryparse(Int, regexresult[:column])
    height = tryparse(Int, regexresult[:height])
    width  = tryparse(Int, regexresult[:width])
    claimer(checkerboard, id, (row, column), (height, width))
end
println(
"The number of cells of with conflicting claims is ",
length(findall(a->a=='x', checkerboard))
)

# Question 3b
for str in strarray
    regexresult = match(r"#(?<id>-?\d+) @ (?<column>\d+),(?<row>\d+): (?<width>\d+)x(?<height>\d+)", str)
    id     = tryparse(Int, regexresult[:id])
    height = tryparse(Int, regexresult[:height])
    width  = tryparse(Int, regexresult[:width])
    claimedcells = height * width
    actualcells = length(findall(a->a==id, checkerboard))
    if claimedcells == actualcells
        println("\nThe id ", id, " has its claims untouched")
    else
        print(id,":",) # For printing loop progress
    end
end
