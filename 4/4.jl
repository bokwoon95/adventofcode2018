import DelimitedFiles
import Dates
import Dates.Date
import Dates.DateTime
strarray = readlines("4.in")

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
    # sort(collect(dict)) changes Dict{DateTime,String} to a Array{Pair{DateTime,String}} sorted by DateTime
    for pair in sort(collect(dict))
        push!(strarraysorted, pair[2])
    end
    strarraysorted
end
strarraysorted = sortbydate(strarray)
DelimitedFiles.writedlm("4.out", strarraysorted, "\n")

let
    dict = Dict{Int,Dict{Date,Array{Int}}}()
    schedule = zeros(Int, 60)
    id = sleep_start = sleep_end = 0
    for str in strarraysorted
        dt = DateTime(match(r"^\[(?<dt>.+)\]", str)[:dt], "yyyy-mm-dd HH:MM")
        re = match(r"Guard #(?<id>\d+)", str)
        if re isa RegexMatch
            if schedule != zeros(Int, 60)
                if id in keys(dict)
                    d = dict[id]
                    d[Date(dt)] = schedule
                else
                    dict[id] = Dict(Date(dt) => schedule)
                end
                schedule = zeros(Int, 60)
            end
            id = re[:id]
        elseif match(r"falls asleep", str) isa RegexMatch
            sleep_start = Dates.minute(dt)
        elseif match(r"wakes up", str) isa RegexMatch
            sleep_end = Dates.minute(dt)
            schedule[sleep_start+1:sleep_end+1] .= 1
        end
    end
end
