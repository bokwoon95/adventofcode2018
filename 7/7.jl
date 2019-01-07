import Base.push!

function readparseinput(filename::String)
    "parses a file, returns an array of tuples (requires, dependency)"
    open(filename, "r") do fh
        arr = Vector{Tuple{Char,Char}}()
        rx = r"^Step (?<dependency>[A-Z]) must be finished before step (?<requires>[A-Z]) can begin"
        for ln in eachline(fh)
            if (re = match(rx, ln)) isa RegexMatch
                push!(arr, (re[:requires][1], re[:dependency][1]))
            end
        end
        arr
    end
end

function resolve_dependencies(dependency_array::Vector{Tuple{Char,Char}})

    # Generate the depedency graph. A dependency graph looks like a dictionary
    # of requires::Char => depedencies::Vector{Char}
    dependency_graph = Dict{Char,Vector{Char}}()
    reqs = Set{Char}()
    deps = Set{Char}()
    for (req, dep) in dependency_array
        if haskey(dependency_graph, req)
            push!(dependency_graph[req], dep)
        else
            dependency_graph[req] = [dep]
        end
        # Also note down the full set of requires/dependency elements
        # This is used in obtaining the initial dependency-free elements
        push!(reqs, req)
        push!(deps, dep)
    end

    # Obtain the initial dependency-free elements to start solving with
    dependencyfree = Vector{Char}()
    for dep in deps
        if !(dep in reqs)
            push!(dependencyfree, dep)
        end
    end

    itrflux = ItrFluxx.init(sort!(dependencyfree))
    finalstr_buf = IOBuffer()

    while !(itrflux.head isa Nothing)
        write(finalstr_buf, itrflux.head)
        for k in keys(dependency_graph)
            removeall!(dependency_graph[k], itrflux.head)
        end
        popped_A = popempty!(dependency_graph)
        push!(itrflux, popped_A)
    end

    dumpstr(finalstr_buf)
end

module ItrFluxx
import Base.push!

mutable struct FlexList{T}
    head::Union{T,Nothing}
    body::Vector{T}
end

function init(arr::Vector{T}) where T
    head = popfirst!(arr)
    body = arr
    flx = FlexList{T}(head, body)
end

function push!(flx::FlexList{T}, arr::Vector{T}) where T
    #= push!(flx.body, arr...) =#
    if length(flx.body) == 0 && length(arr) == 0
        flx.head = nothing
    else
        push!(flx.body, arr...)
        flx.head = popfirst!(sort!(flx.body))
    end
    nothing
end

end # module ItrFlux

### Start Here ###
function main()
    # Question 7a
    dependency_array = readparseinput("7.in")
    ans7a = resolve_dependencies(dependency_array)
    println("The correct steps should be: $ans7a")
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
@inline function removeall!(arr::Vector{T}, t::T) where T
    "Remove all instances of t::T from arr::Vector{T}"
    indices = Int[]
    for i in eachindex(arr)
        if arr[i] == t
            push!(indices, i)
        end
    end
    deleteat!(arr, indices)
end
@inline function popempty!(dict::Dict{T,Vector{T}}) where T
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

isinteractive() || @time main()
