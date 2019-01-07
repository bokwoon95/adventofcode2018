const InputArray = Array{Tuple{Char,Char},1}
const Graph = Dict{Char,Array{Char,1}}

function readparseinput(filename::String)
    "parses a file, returns an array of tuples (:requires, :dependency)"
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

function resolve_dependencies(inputarray::InputArray)

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

    graph = makegraph(inputarray)
    graph_dc = deepcopy(graph) # make a copy for graph deconstruction
    finalstr_buf = IOBuffer()

    itrflux = ItrFlux.init(inputarray)

    failsafe = 50
    while !(itrflux.head isa Nothing)
        write(finalstr_buf, itrflux.head)
        for k in keys(graph_dc)
            removeall!(graph_dc[k], itrflux.head)
        end
        popped_A = popempty!(graph_dc)
        push!(itrflux, popped_A)
        failsafe-=1; if failsafe<=0 println("failsafe activated");break end
    end

    dumpstr(finalstr_buf)
end

module ItrFlux
const InputArray = Array{Tuple{Char,Char},1}
import Base.push!

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

function push!(t::T, arr::Array{Char,1})
    if length(t.body) == 0 && length(arr) == 0
        t.head = nothing
    else
        push!(t.body, arr...)
        t.head = popfirst!(sort!(t.body))
    end
    nothing
end

end #ItrFlux

### Start Here ###
function main()
    # Question 7a
    inputarray = readparseinput("7.in")
    println("The correct steps should be: " * resolve_dependencies(inputarray))
end

# helper functions
@inline function dumpstr(io::IOBuffer)
    "dump IOBuffer as String without affecting the internal ptr"
    ptr = io.ptr
    seekstart(io)
    str = String(map(Char, read(io)))
    io.ptr = ptr
    str
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
@inline function popempty!(dict::Dict{T,Array{T,1}}) where {T}
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
import Base.foreach
function foreach(f::Function, dict::Dict)
end

isinteractive() || @time main()
