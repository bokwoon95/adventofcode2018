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

# Maybe a struct to hold the current status at each iteration would be a godsend here?

let
    dict = Dict{Int,Array{Int}}()
    schedule = zeros(Int, 60)
    id = sleep_start = sleep_end = 0
    firstloop = true
    for str in strarraysorted
        dt = DateTime(match(r"^\[(?<dt>.+)\]", str)[:dt], "yyyy-mm-dd HH:MM")
        re = match(r"Guard #(?<id>\d+)", str)
        if re isa RegexMatch
            if firstloop
                id_curr = re[:id]
                firstloop = false
            else
                id_prev = id_curr
                id_curr = re[:id]
                #> Insert entry for id_prev, schedule
                    # I think date is not important to store because as long as the date differs we know we have to store a new schedule inside
            end
            schedule = zeros(Int, 60)
        elseif match(r"falls asleep", str) isa RegexMatch
            sleep_start = Dates.minute(dt)
        elseif match(r"wakes up", str) isa RegexMatch
            sleep_end = Dates.minute(dt)
            schedule[sleep_start+1:sleep_end] .= 1
        end
    end
end
