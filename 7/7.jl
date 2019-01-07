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
    end::Vector{Tuple{Char,Char}}
end

mutable struct FlexList{T}
"FlexList works like an iterable array, except you can dynamically change the
body of the flexlist while you are iterating over it. At any one time you only
have to read the head of the FlexList, allowing for elements to be freely
inserted into and deleted from the body without affecting the head. At the end
of the loop call next!() on the FlexList to push the next element of the body
into the head. When there are no more elements in the body, the head is
assigned `nothing`. The termination condition of a flexlist iteration is thus
when the head isa Nothing"
    head::Union{T,Nothing}
    body::Vector{T}
end
@inline function init(::Type{FlexList{T}}, arr::Vector{T}) where T
    head = popfirst!(arr)
    body = arr
    FlexList{T}(head, body)
end
@inline function next!(flx::FlexList{T}) where T
    if length(flx.body) == 0
        flx.head = nothing
    else
        flx.head = popfirst!(flx.body)
    end::Union{T,Nothing}
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

    flx = init(FlexList{Char}, sort!(dependencyfree))
    str_buf = IOBuffer()
    ### Start Here ###
    while !(flx.head isa Nothing)
        write(str_buf, flx.head)
        for k in keys(dependency_graph)
            removeall!(dependency_graph[k], flx.head)
        end
        push!(flx.body, popempty!(dependency_graph)...)
        sort!(flx.body)
        next!(flx)
    end
    dumpstr(str_buf)::String
end

function main()
    # Question 7a
    dependency_array = readparseinput("7.in")
    ans7a = resolve_dependencies(dependency_array)
    println("The correct steps should be: $ans7a");
end

# helper functions
@inline function dumpstr(io::IOBuffer)
    "dump IOBuffer as String without affecting the internal ptr"
    ptr = io.ptr
    seekstart(io)
    str = String(map(Char, read(io)))
    io.ptr = ptr
    str::String
end
@inline function removeall!(arr::Vector{T}, t::T) where T
    "Remove all instances of t::T from arr::Vector{T}"
    indices = Int[]
    for i in eachindex(arr)
        if arr[i] == t
            push!(indices, i)
        end
    end
    deleteat!(arr, indices);
end
@inline function popempty!(dict::Dict{T,Vector{T}}) where T
    "deletes all keys with empty value arrays in the dictionary and returns the
    list of deleted keys"
    deleted = Vector{T}()
    for k in keys(dict)
        if dict[k] == Array{T,1}()
            delete!(dict, k)
            push!(deleted, k)
        end
    end
    deleted::Vector{T}
end

isinteractive() || @time main()
