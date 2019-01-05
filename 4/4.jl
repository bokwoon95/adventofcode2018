import Dates
import Dates.Date
import Dates.DateTime
import DelimitedFiles

function sortbydate(strarray::Array{String,1})
    """
    Takes in an array of strings, parses the dates
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
        if (re = match(r"Guard #(?<id>\d+)", str)) isa RegexMatch
            id = parse(Int, re[:id])
            if !(ls.id isa Nothing)
                if haskey(dict, ls.id)
                    push!(dict[ls.id], schedule)
                else
                    dict[ls.id] = [schedule]
                end
            end
            ls.id = id
            ls.sleep_start = nothing
            ls.sleep_end = nothing
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

mutable struct FourA
    """
    Holds the status of the guard with the most hours slept
    """
    id::Int
    hoursslept::Int
    worstminute::Int
end

mutable struct FourB
    """
    Holds the status of the guard who is asleep the most at a particular minute
    """
    id::Int
    hoursslept::Int
    worstminute::Int
end

function question4(dict::Dict{Int64,Array{Array{Int64,1},1}})
    fourA = FourA(-1, -1, -1)
    fourB = FourB(-1, -1, -1)
    for id in keys(dict)
        array2D = hcat(dict[id]...)
        array1D = reduce(+, array2D, dims=2)
        hoursslept_A = reduce(+, array1D, dims=1)[1,1]
        worstminute = findmax(array1D, dims=1)[2][1,1][1] - 1
        hoursslept_B = findmax(array1D, dims=1)[1][1,1]
        #= println("#$id, $hoursslept_A total hours slept, slept the most ($hoursslept_B hours) at $worstminute min") =#
        if hoursslept_A > fourA.hoursslept
            fourA.id = id
            fourA.hoursslept = hoursslept_A
            fourA.worstminute = worstminute
        end
        if hoursslept_B > fourB.hoursslept
            fourB.id = id
            fourB.hoursslept = hoursslept_B
            fourB.worstminute = worstminute
        end
    end
    # Question 4a
    println("\nThe laziest guard is #$(fourA.id) ($(fourA.hoursslept) hours), sleeping the most at minute $(fourA.worstminute)")
    println("$(fourA.id) x $(fourA.worstminute) is $(fourA.id * fourA.worstminute)")
    # Qeustion 4b
    println("\nThe guard who slept the most at a particular minute is #$(fourB.id), sleeping for $(fourB.hoursslept) hours at minute $(fourB.worstminute)")
    println("$(fourB.id) x $(fourB.worstminute) is $(fourB.id * fourB.worstminute)")
end

function main()
    strarray = readlines("4.in")
    strarraysorted = sortbydate(strarray)
    DelimitedFiles.writedlm("4.out", strarraysorted, "\n")
    dict = arraytodict(strarraysorted)
    question4(dict)
end

isinteractive() || @time main()
