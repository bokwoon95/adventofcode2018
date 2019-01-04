function react(instring::String, exclusionlist::Char...)
    # old @time = 52.356412 seconds (76.84 k allocations: 12.560 MiB, 0.01% gc time)
    # new @time = 0.007507 seconds (100.00 k allocations: 4.722 MiB)
    io = IOBuffer()
    for char in instring
        if char in exclusionlist
            continue
        end
        if position(io) != 0 && checkpolarity(char, nthchar(io, io.ptr - 1))
            io.ptr -= 1
        else
            write(io, char)
        end
    end
    outstring = chomp(dumpstr(io, io.ptr - 1))
end

function main()
    bigstring = open("5.in", "r") do fh
        read(fh, String)
    end
    # Question 5a
    println("The length of the reacted polymer is $(length(react(bigstring)))")
    # Question 5b
    shortestlength::Union{Int,Nothing} = nothing
    removedchar = '\0'
    for ch in 'a':'z'
        len = length(react(bigstring, ch, ch - 32))
        if shortestlength isa Nothing || len < shortestlength
            shortestlength = len
            removedchar = ch
        end
    end
    println("The shortest length possible is $shortestlength by removing $removedchar/$(removedchar - 32)")
end

# helper functions
@inline function checkpolarity(c1::Char, c2::Char)
    c1 + 32 == c2 || c2 + 32 == c1
end
@inline function dumpstr(io::IOBuffer)
    "dump io as String"
    ptr = io.ptr
    seekstart(io)
    str = String(map(Char, read(io)))
    io.ptr = ptr
    str
end
@inline function dumpstr(io::IOBuffer, int::Int)
    "dump io as String up to `int` bytes"
    ptr = io.ptr
    seekstart(io)
    str = String(map(Char, read(io, int)))
    io.ptr = ptr
    str
end
@inline function nthchar(io::IOBuffer, n::Int)
    "Returns the nth character in io"
    ptr = io.ptr
    seek(io, n-1)
    ch = n == 0 ? Char(0) : Char(read(io, 1)[1])
    io.ptr = ptr
    ch
end
