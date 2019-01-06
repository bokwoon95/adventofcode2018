const InputArray = Array{Tuple{Char,Char},1}
const Graph = Dict{Char,Array{Char,1}}

function readinput(filename::String)
    open(filename, "r") do fh
        arr = InputArray()
        rx = r"^Step (?<dependency>[A-Z]) must be finished before step (?<requires>[A-Z]) can begin"
        for ln in eachline(fh)
            if (re = match(rx, ln)) isa RegexMatch
                push!(arr, (re[:requires][1], re[:dependency][1]))
            end
        end
        arr
    end
end

function resolvedeps(inputarray::InputArray)
    fh = open("7.log", "w")

    function makegraph(inputarray::InputArray)
        "Given an inputarray of requirements, construct a dependency graph out
        of it. A dependency graph looks like a dictionary of require::Char =>
        depedencies::Array{Char,1}"
        graph = Graph()
        for tup in inputarray
            req, dep = tup
            if haskey(graph, req)
                push!(graph[req], dep)
            else
                graph[req] = [dep]
            end
        end
        graph
    end

    global removechars = function(a1::Array{Char,1}, a2::Array{Char,1})
        "Remove from the first array all instances of characters that are present in the second array"
        a3 = Array{Char,1}()
        for c in a1
            if !(c in a2)
                push!(a3, c)
            end
        end
        a3
    end

    global graph = makegraph(inputarray)
    global graph_dc = deepcopy(graph) # make a copy for graph deconstruction

    # jot down the full set of reqs and deps
    global reqs = Set{Char}()
    global deps = Set{Char}()
    for (req, dep) in inputarray
        push!(reqs, req)
        push!(deps, dep)
    end

    # get the dependency-free first element(s)
    global nodeps1 = Array{Char,1}()
    global nodeps2 = Array{Char,1}()
    global nodeps3 = Array{Char,1}()
    for dep in deps
        if !(dep in reqs)
            push!(nodeps1, dep)
        end
    end
    nodeps1 = sort(nodeps1)

    # keep looping
    failsafe = 50
    while length(graph_dc) > 0
        println(fh, graph_dc)
        println(fh, "nodeps1 was $nodeps1")
        println(fh, "nodeps2 was $nodeps2")
        println(fh, "nodeps3 was $nodeps3")
        println(fh, "---")
        nodeps3 = cat(nodeps3, ['-'], sort(nodeps2), dims=1)
        nodeps2 = deepcopy(nodeps1)
        nodeps1 = Array{Char,1}()
        for key in keys(graph_dc)
            graph_dc[key] = removechars(graph_dc[key], nodeps2)
            if length(graph_dc[key]) == 0
                delete!(graph_dc, key)
                push!(nodeps1, key)
            end
        end
        # failsafe
        failsafe -= 1
        if failsafe == 0
            println("failsafe activated")
            break
        end
    end
    close(fh)
    String(nodeps3)
end

function main()
    # Question 7a
    global inputarray = readinput("7.in")
    resolvedeps(inputarray)
end

isinteractive() || @time main()
