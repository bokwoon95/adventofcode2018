# old @time = 52.356412 seconds (76.84 k allocations: 12.560 MiB, 0.01% gc time)
# TODO
# ----
# Change the algorithm such that it's a one-pass only!
# Use a 'pointer' to keep track of what the last element inserted is
# Whenever there's a reaction, delete the last element and move the pointer in by one
# Combined with the IOBuffer, this should make the react() operation very fast
# The only problem is figuring out how to 'pop' a character out of the IOBuffer
function react(instring::String)
    outstring = ""
    io = IOBuffer()
    prevchar::Union{Char,Nothing} = nothing
    loop = true; while loop
        for i in 1:length(instring)
            thischar = instring[i]
            if prevchar isa Nothing
                prevchar = thischar
            elseif prevchar + 32 == thischar || thischar + 32 == prevchar
                prevchar = nothing
            elseif i == length(instring)
                write(io, prevchar)
                write(io, thischar)
                prevchar = nothing
            else
                write(io, prevchar)
                prevchar = thischar
            end
        end
        outstring = String(take!(io))
        @show length(instring)
        @show length(outstring)
        if length(instring) <= length(outstring)
            loop = false; break
        else
            instring = outstring
            println("Feeding outstring back in as instring..\n")
        end
    end
    outstring
end

function main()
    bigstring = open("5.in", "r") do fh
        read(fh, String)
    end
    react(bigstring)
end
