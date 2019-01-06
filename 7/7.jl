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

    @inline function makegraph(inputarray::InputArray)
        "Given an inputarray of requirements, construct a dependency graph out
        of it. A dependency graph looks like a dictionary of requires::Char =>
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

    @inline function removeall!(arr::Array{T,1}, t::T) where {T}
        "Remove all instances of t::T from arr::Array{T,1}"
        indices = Int[]
        for i in eachindex(arr)
            if arr[i] == t
                push!(indices, i)
            end
        end
        deleteat!(arr, indices)
    end

    function popempty!(dict::Dict{T,Array{T,1}}) where {T}
        "deletes all keys with empty value arrays in the dictionary and returns the
        list of deleted keys"
        deleted = Array{T,1}()
        for k in keys(dict)
            if dict[k] == Array{T,1}()
                delete!(dict, k)
                push!(deleted, k)
            end
        end
        deleted
    end

    global graph = makegraph(inputarray)
    global graph_dc = deepcopy(graph) # make a copy for graph deconstruction
    global finalstr_buf = IOBuffer()

    available = FluxItr.init(inputarray)
    println(available)

    failsafe = 1
    while !(available.head isa Nothing)
        write(finalstr_buf, available.head)
        for k in keys(graph_dc)
            removeall!(graph_dc[k], available.head)
        end
        popped_A = popempty!(graph_dc)
        FluxItr.push!(available, popped_A)
        failsafe-=1; if failsafe<=0 println("failsafe activated");break end
    end
    println(dumpstr(finalstr_buf))
    println(String(t.body))

    close(fh)
end

module FluxItr
import Base.push!

const InputArray = Array{Tuple{Char,Char},1}
const Graph = Dict{Char,Array{Char,1}}

mutable struct T
    head::Union{Char,Nothing}
    body::Array{Char,1} # Must always be sorted
end

function init(inputarray::InputArray)
    t = T(nothing, Char[])
    temp = Array{Char,1}()
    reqs = Set{Char}()
    deps = Set{Char}()
    for (req, dep) in inputarray
        push!(reqs, req)
        push!(deps, dep)
    end
    for dep in deps
        if !(dep in reqs)
            push!(temp, dep)
        end
    end
    t.head = popfirst!(sort!(temp))
    t.body = temp
    t
end

# TODO Run @M 7. Why does this fail?
#= ERROR: MethodError: no method matching push!(::Main.FluxItr.T, ::Array{Char,1}) =#
#= Closest candidates are: =#
#=   push!(::Any, ::Any, ::Any) at abstractarray.jl:2064 =#
#=   push!(::Any, ::Any, ::Any, ::Any...) at abstractarray.jl:2065 =#
#=   push!(::Array{Any,1}, ::Any) at array.jl:862 =#
function push!(t::T, arr::Array{T,1})
    if length(arr) == 0
        t.head = nothing
    else
        push!(t.body, arr...)
        t.head = popfirst!(sort!(t.body))
    end
    nothing
end

end #FluxItr

function main()
    # Question 7a
    global inputarray = readinput("7.in")
    resolvedeps(inputarray)
end

# helper functions
@inline function dumpstr(io::IOBuffer)
    "dump io as String"
    ptr = io.ptr
    seekstart(io)
    str = String(map(Char, read(io)))
    io.ptr = ptr
    str
end

isinteractive() || @time main()
