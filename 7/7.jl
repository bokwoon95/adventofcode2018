@inline function readparseinput(filename::String)
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

# Question 7a

module FlexList
mutable struct Dt{T}
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
@inline function init(arr::Vector{T}) where T
    head = popfirst!(arr)
    body = arr
    Dt{T}(head, body)
end
@inline function next!(flx::Dt{T}) where T
    if length(flx.body) == 0
        flx.head = nothing
    else
        flx.head = popfirst!(flx.body)
    end::Union{T,Nothing}
end
end

@inline function generate_dependency_graph(dependency_array::Vector{Tuple{Char,Char}})
    # Generate the dependency graph. A dependency graph looks like a dictionary
    # of requires::Char => dependencies::Vector{Char}
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
    dependency_free = Vector{Char}()
    for dep in deps
        if !(dep in reqs)
            push!(dependency_free, dep)
        end
    end
    dependency_graph, dependency_free
end

@inline function resolve_dependencies(dependency_graph::Dict{Char,Vector{Char}}, dependency_free::Vector{Char})
    dependency_graph = deepcopy(dependency_graph)
    dependency_free = deepcopy(dependency_free)
    flx = FlexList.init(sort!(dependency_free))
    str_buf = IOBuffer()

    ### Start Here ###
    while truthy(flx.head)
        write(str_buf, flx.head)
        for k in keys(dependency_graph)
            removeall!(dependency_graph[k], flx.head)
        end
        push!(flx.body, popempty!(dependency_graph)...)
        sort!(flx.body)
        FlexList.next!(flx)
    end
    dumpstr(str_buf)::String
end

# Question 7b

module SweatShop
import Main.FlexList
mutable struct Dt
    t::Vector{Vector{Union{Char,Int,Nothing}}}
    length::Int
    available::Vector{Int}
end
@inline function init(n::Int)
    arr = Dt.types[1]()
    length = n
    available = collect(1:n)
    for i in 1:n
        push!(arr, [nothing, 0])
    end
    Dt(arr, length, available)
end
@inline function allocate!(swsh::Dt, flx::FlexList.Dt)
    while length(swsh.available) != 0 && !(flx.head isa Nothing)
        swsh.t[popfirst!(swsh.available)] = [flx.head, gettime(flx.head)]
        FlexList.next!(flx)
    end
    length(swsh.available) != 00, !(flx.head isa Nothing)
end
@inline function free!(swsh::Dt)
    min::Union{Int,Nothing} = nothing
    for i in eachindex(swsh.t)
        if min isa Nothing || swsh.t[i][2] < min
            min = swsh.t[i][2]
            println("min is $min")
        end
    end
    for i in eachindex(swsh.t)
        swsh.t[i][2] - min
    end
    min
end
@inline gettime(ch::Char) = Int(ch) - 4
end

function calculatetime(dependency_graph::Dict{Char,Vector{Char}}, dependency_free::Vector{Char})
    global swsh = SweatShop.init(5)
    global flx = FlexList.init(sort!(dependency_free))
    elapsed = 0
    while truthy(flx.head)
        for k in keys(dependency_graph)
            removeall!(dependency_graph[k], flx.head)
        end
        loop = true; while loop
            swsh_full, flx_empty = SweatShop.allocate!(swsh, flx)
            if swsh_full && !flx_empty
                elapsed += SweatShop.free!(swsh)
            elseif flx_empty && !swsh_full
                loop = false; break
            end
        end
        push!(flx.body, popempty!(dependency_graph)...)
        sort!(flx.body)
        elapsed += 1
        FlexList.next!(flx)
    end
    elapsed
end

function main()
    dependency_array = readparseinput("7.in")
    dependency_graph, dependency_free = generate_dependency_graph(dependency_array)
    # Question 7a
    ans7a = resolve_dependencies(dependency_graph, dependency_free)
    println("The correct steps should be: $ans7a");
    # Question 7b
    ans7b = calculatetime(dependency_graph, dependency_free)
    println("The time taken to complete all the steps is: $ans7b");
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
        if dict[k] == Vector{T}()
            delete!(dict, k)
            push!(deleted, k)
        end
    end
    deleted::Vector{T}
end
truthy(b::Bool) = b
truthy(i::Int) = i != 0
truthy(x::Any) = !(x isa Nothing || x isa Missing)
falsy(b::Bool) = !b
falsy(i::Int) = i == 0
falsy(x::Any) = x isa Nothing || x isa Missing

isinteractive() || @time main()
