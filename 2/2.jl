strarray = readlines("2.in") # parse each line of 2.in into a string array

# Question 2a
function getcounts(str::String)
    """
    returns [twocount, threecount], where
    twocount is 1 if there is at least one character occurring exactly 2 times else it is 0
    threecount is 1 if there is at least one character occurring exactly 3 times else it is 0
    """
    d = Dict{Char, Integer}()
    # convert string into dictionary of character => occurences
    for ch in str
        d[ch] = haskey(d, ch) ? d[ch] + 1 : 1
    end
    twocount = threecount = 0
    for (k, v) in d
        twocount   = v == 2 ? 1 : twocount
        threecount = v == 3 ? 1 : threecount
    end
    return [twocount threecount]
end

a = map(getcounts, strarray) # pass each string through getcounts()
b = vcat(a...) # concatenate all the 2-element arrays vertically
c = reduce(+, b, dims=1) # obtain sum of each column
d = reduce(*, c, dims=2) # obtain product of each row
println("The checksum is ", d[1])

# Question 2b
function correctpair(s1::String, s2::String)
    """
    Checks two strings to see if they differ by exactly 1 character
    If they do, returns true as well as the string without the mismatched character
    Else return false and nothing
    """
    # if string lengths do not match, immediately return false
    if length(s1) != length(s2) return false, nothing end
    mismatches = 0
    mismatchindex = nothing
    for i in collect(1:length(s1))
        # count the number of mismatched characters and note down the last mismatched character's index
        if s1[i] != s2[i]
            mismatches += 1
            mismatchindex = i
        end
    end
    if mismatches == 1
        # splice the mismatched character out
        return true, s1[1:mismatchindex-1] * s1[mismatchindex+1:end]
    end
    return false, nothing
end

let
    copyarr = copy(strarray)
    loop = true
    while length(copyarr) > 1 && loop
        refstring = popfirst!(copyarr)
        for str in copyarr
            result = correctpair(refstring, str)
            if result[1]
                println("The common letters in the two correct box IDs are ", result[2])
                loop = false; break
            end
        end
    end
end
