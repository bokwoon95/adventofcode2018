import Dates
import Dates.Date
import Dates.DateTime
import DelimitedFiles

function sortbydate(strarray::Array{String,1})
    """
    Takes in an array of strings, extracts the dates
    and sorts the strings by the dates. Returns an array
    of the sorted strings
    """
    dict = Dict{DateTime,String}()
    # extract the datetime and store it in an intermediate dictionary Dict{DateTime,String}
    for str in strarray
        dt = DateTime(match(r"^\[(?<dt>.+)\]", str)[:dt], "yyyy-mm-dd HH:MM")
        dict[dt] = str
    end
    strarraysorted = String[]
    # sort(collect(dict)) changes Dict{DateTime,String} to a Array{Pair{DateTime,String}} sorted by the DateTime
    for pair in sort(collect(dict))
        push!(strarraysorted, pair[2])
    end
    strarraysorted
end

mutable struct LoopStatus
    """
    Used to hold the current status at each iteration
    """
    id::Union{Int,Nothing}
    sleep_start::Union{Int, Nothing}
    sleep_end::Union{Int, Nothing}
end

function arraytodict(strarraysorted::Array{String})
    """
    Parses a string array and returns a dictionary Dict{Int,Array{Array{Int,1},1}}
    of 'Guard ID' => 'Sleep/Wake schedule'
    """
    dict = Dict{Int,Array{Array{Int,1},1}}()
    schedule = zeros(Int, 60)
    id = sleep_start = sleep_end = nothing
    ls = LoopStatus(nothing, nothing, nothing)
    for str in strarraysorted
        dt = DateTime(match(r"^\[(?<dt>.+)\]", str)[:dt], "yyyy-mm-dd HH:MM")
        re = match(r"Guard #(?<id>\d+)", str)
        if re isa RegexMatch
            id = tryparse(Int, re[:id])
            if ls.id isa Nothing
                ls.id = id
            else
                if haskey(dict, ls.id)
                    push!(dict[ls.id], schedule)
                else
                    dict[ls.id] = [schedule]
                end
                ls.id = id
                ls.sleep_start = nothing
                ls.sleep_end = nothing
            end
            schedule = zeros(Int, 60)
        elseif match(r"falls asleep", str) isa RegexMatch
            ls.sleep_start = Dates.minute(dt)
        elseif match(r"wakes up", str) isa RegexMatch
            ls.sleep_end = Dates.minute(dt)
            schedule[ls.sleep_start+1:ls.sleep_end] .= 1
        end
    end
    dict
end

mutable struct Laziest
    id::Int
    hoursslept::Int
    worstminute::Int
end

function main()
    strarray = readlines("4.in")
    strarraysorted = sortbydate(strarray)
    DelimitedFiles.writedlm("4.out", strarraysorted, "\n")
    dict = arraytodict(strarraysorted)
    laziestguard = Laziest(-1, -1, -1)
    for id in keys(dict)
        array2D = hcat(dict[id]...)
        array1D = reduce(+, array2D, dims=2)
        hoursslept = reduce(+, reduce(+, array2D, dims=2), dims=1)[1,1]
        worstminute = findmax(array1D, dims=1)[2][1,1][1] - 1
        println("$id, $hoursslept, $worstminute")
        if hoursslept > laziestguard.hoursslept
            laziestguard.id = id
            laziestguard.hoursslept = hoursslept
            laziestguard.worstminute = worstminute
        end
    end
    laziestguard.id,laziestguard.hoursslept,laziestguard.worstminute
end
#= sleep = max(reduce(+, hcat(dict[id]...), dims=2)...) =#

isinteractive() || main()
