const ArrayOfXY = Array{Array{Int,1},1}
const Board = Array{Union{Int,Nothing},2}

function readinput(filename::String="6.in")::ArrayOfXY
    """
    in: filename::String
    Parses a file and extracts the digits of each tuple for each line
    out: Array of x,y coordinates. The index of each array element serves as its unique id
    """
    arrayofXY = ArrayOfXY()
    open(filename, "r") do fh
        for ln in eachline(fh)
            re = match(r"^(?<first>\d+)\s*,\s*(?<second>\d+)s*$", ln)
            if re isa RegexMatch
                first = tryparse(Int, re[:first])
                second = tryparse(Int, re[:second])
                push!(arrayofXY, [first + 1, second + 1]) # all coords have to add 1 due to Julia 1-indexing
            end
        end
    end
    arrayofXY
end

function generate_initial_board(arrayofXY::ArrayOfXY)::Board
    maxdims = reduce(max, hcat(arrayofXY...), dims=2) # obtain the highest value for each x and y column, so we know how large board has to be initialized to
    board = Board(nothing, maxdims[1], maxdims[2])
    for i in eachindex(arrayofXY)
        x, y = arrayofXY[i]
        board[x,y] = i
    end
    board
end

function question6a(board::Board, arrayofXY::ArrayOfXY)

    function getclosestXY(board::Board, fixedpoint::Tuple{Int,Int}, arrayofXY::ArrayOfXY)
        "calculates the mahattan distance between fixedpoint and every point in arrayofXY and returns the point with the shortest distance"
        shortestdistance::Union{Float64,Nothing} = nothing
        closestXY::Union{Int,Nothing} = nothing
        maxX, maxY = size(board)
        px, py = fixedpoint
        for i in eachindex(arrayofXY)
            x, y = arrayofXY[i]
            distance = abs(px - x) + abs(py - y) # manhattan formula
            if shortestdistance isa Nothing || distance < shortestdistance
                shortestdistance = distance
                closestXY = i
            elseif distance == shortestdistance
                closestXY = -1 # -1 means the fixedpoint is equally close between two or more points in arrayofXY
            end
        end
        closestXY
    end

    area_dictionary = Dict{Int,Int}() # id => totalarea, only contains ids with finite area
    infinity_exclusion_list = Array{Int,1}() # ids which lie on the edge, and hence whose areas extend to infinity. This list is mutually exclusive with area_dictionary
    maxX, maxY = size(board)
    for i in 1:maxX
        for j in 1:maxY
            if board[i,j] isa Nothing
                closestXY = getclosestXY(board, (i, j), arrayofXY)
                if i == 1 || i == maxX || j == 1 || j == maxY
                    if !(closestXY in infinity_exclusion_list)
                        push!(infinity_exclusion_list, closestXY)
                    end
                    if closestXY in keys(area_dictionary)
                        delete!(area_dictionary, closestXY)
                    end
                end
                if closestXY != -1 && !(closestXY in infinity_exclusion_list)
                    area_dictionary[closestXY] = haskey(area_dictionary, closestXY) ? area_dictionary[closestXY] += 1 : 2 # start with 2 because every id starts with one point on the board even before any allocation starts
                end
                board[i,j] = closestXY
            end
        end
    end
    area_dictionary
end

function question6b(board::Board, arrayofXY::ArrayOfXY)::Int
    maxX, maxY = size(board)
    finalarea = 0
    for i in 1:maxX
        for j in 1:maxY
            finaldist = 0
            for k in eachindex(arrayofXY)
                x, y = arrayofXY[k]
                finaldist += abs(x - i) + abs(y - j)
            end
            if finaldist < 10000
                finalarea += 1
            end
        end
    end
    finalarea
end

function main()
    arrayofXY = readinput()
    initial_board = generate_initial_board(arrayofXY)
    # Question 6a
    area_dictionary = question6a(deepcopy(initial_board), arrayofXY)
    println("The largest finite area is $(findmax(area_dictionary)[1])")
    # Question 6b
    area_within_10000 = question6b(initial_board, arrayofXY)
    println("The area within 10000 is $area_within_10000")
end

isinteractive() || main()
