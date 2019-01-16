#= https://github.com/MaxNoe/adventofcode2018/blob/master/src/Day7.jl =#
module Day7
export parse_input, build_dag, part_1, part_2

pattern = r"Step (\w) must be finished before step (\w) can begin"

function parse_input(input::String)::Vector{Vector{String}}
    return map(
        l -> match(pattern, l).captures,
        split(strip(input), "\n")
    )
end

function build_dag(parsed_input)::Vector{Vector{String}}
    dag = Dict{String, Array{String}}()
    for (dependency, target) in parsed_input
        if !in(target, keys(dag)) 
            dag[target] = [dependency]
        else
            push!(dag[target], dependency)
        end

        if !in(dependency, keys(dag))
            dag[dependency] = []
        end
    end
    return dag
end


function part_1(dag)
    dag = deepcopy(dag)
    order = ""
    while length(dag) > 0
        possible = collect(filter(k -> length(dag[k]) == 0, keys(dag)))
        sort!(possible)

        next = possible[1]
        pop!(dag, next)
        order *= next

        for dependencies in values(dag)
            filter!(l -> l != next, dependencies)
        end
    end
    return order
end

function part_2(dag; workers=2, per_task=0)
    dag = deepcopy(dag)
    done_at = Dict{String, Int}()
    free_workers = workers

    t = -1
    while (length(dag) > 0) | (length(done_at) > 0)
        t += 1

        for task_done in filter(k -> done_at[k] == t, keys(done_at))
            pop!(done_at, task_done)
            free_workers += 1

            for dependencies in values(dag)
                filter!(l -> l != task_done, dependencies)
            end

        end

        if free_workers == 0
            continue
        end

        possible = collect(filter(k -> length(dag[k]) == 0, keys(dag)))

        if length(possible) == 0
            continue
        end

        sort!(possible)
        n_possible = min(length(possible), free_workers)

        for i in 1:n_possible
            next = possible[i]
            pop!(dag, next)
            free_workers -= 1
            done_at[next] = t + per_task + next[1] - 'A' + 1
        end
    end

    return t
end

end
