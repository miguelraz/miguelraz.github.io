@def title = "Parsing Basics with Parsers.jl"
@def tags = ["parsing", "parsers"]

\tableofcontents

### Parsing basics - how to use Parsers.jl to parse formats for high performance

~ 20 minutes.
* This post talks about parsing, aka how to read file. It is focused on formats of interest for scientific / data processing, but is meant more as an introduction than a complete overview.
* We will use Julia, Parsing.jl, and will be trying to parse the [DOT](X) and [EdgeList](X) formats.
* This post draws from my experience rewriting a graph formats parsing library, [LightGraphsIO](X), and is intended to be documentation / a tutorial for others / Parsers.jl who may venture into similar waters.
* Special shout out to the LightGraphs.jl contributors and to Jacob Quinn, who kindly answered my questions about his Parsers.jl library.

### What is parsing?

For us, parsing involves reading data from a file. They usually have a specification for how the file should be structured.

### Why should I care?

Some programming tasks will require you to read data and not be stuck all day waiting for the data to load (as it was our case.).
If it's a bottleneck for your work, consider diving in! Otherwise, its probably best to just call a library to handle it.

### How fast can you go?
Quite fast, depending on your approach. The "simplest" (but by no means trivial) kind of parsing is byte-at-a-time.
You look at one character, and depending on what you've seen, decide what to do, and push it into a relevant data structure and keep going.
That approach hits a roof of about ( ) according to these calculations by Daniel Lemire, an absolute pro at this sort of stuff.
His team's approach let's them parse some formats at a whopping ( ) by using SIMD vectorization (aka, oodles of parallelism, very close to assembly level).
We may cover that approach in a later post, but for now we'll be happy with Parsers.jl that does some clever byte-at-a-time optimizations to still get respectable for our needs.

### Oooh - what are these tricks?

We'll do some Memory mapping and using bitmasks. Don't worry, this all comes "out of the box" in Julia.

Briefly:
- *memory mapping* : Convert a file to a vector of bytes. This will ideally greatly improved the processing speed of your file.

You can do this in Julia with a simple

```julia-repl
julia> using Mmap
julia> mm = Mmap.mmap("file.txt")
```

- *bit masks* : Instead of using several variables for many binary conditions, we stick them all in a single memory chunk and use bit operations to get out the useful information.

Which usually looks like

```julia-repl
julia> 0b01 & 1 # notice the 0b01 is a binary literal
```

### The format to be parse

We'll get start with a `EdgeList` (called `"simple.edgelist"`) file, they look like this:


```
6 7
1 2
2 3
6 3
5 6
2 5
2 4
4 1
```

Where the first two digits correspond to `n` edges and `m` vertices, and the file has `m` lines.

```julia-repl
julia> using Mmap, Parsers

julia> const opts = Parsers.Options(delim = ' ', wh1 = 0x00)

julia> function read_two(file)
            # 1. MMap the file 
            io = Mmap.mmap(file)

            # 2. call xparse
            pos = 1
            x, code, vpos, vlen, tlen = Parsers.xparse(Int, io, pos, sizeof(io), opts)

            # 3. Advance the cursor by the 'tab length'
            pos += tlen
            y, code, vpos, vlen, tlen = Parsers.xparse(Int, io, pos, sizeof(io), opts)
            x, y
            
            # 4. Oops! skipped error handling!
       end
```


This is one of the "easier" cases that Parsers.jl can handle, so let's break down `read_two("simple.edgelist")`:

```julia-repl
julia> read_two("simple.edgelist", EdgeListFormat) == (6, 7)
true
```

##### TODO ??? 

1. Setup the appropriate [Parsers.Options](https://github.com/JuliaData/Parsers.jl/blob/589b9d0f80998ec284874b300da0932557d33513/src/Parsers.jl#L8) struct, which will dispatch on the parsing behavior. We're basically wrapping up all the presets for this file that are important: our delimiter is the `' '` whitespace character and the `wh1` == ???
2. We use the `Mmap` trick to convert our file into a stream of bytes to get a performance boost.
3. The argumnents to `xparse` tell you where and what to start parsing `Parsers.xparse(Int, io, pos, sizeof(io), opts)` :
    - `Int` - Type of the value we are parsing
    - `io` - handler to the io stream
    - `pos` - to know where to start parsing
    - `sizeof(io)` - to know if you have reached the end of `io`
    - `opts` - to handle our parsing options.
4. We get a bunch of variables back from `xparse` - the docstrings [here are quite overwhelming](https://github.com/JuliaData/Parsers.jl/blob/589b9d0f80998ec284874b300da0932557d33513/src/Parsers.jl#L148) but it's not too bad once we stare at it for a while:
    - `x` is the value we parsed, `6` in this case.
    -  `code` is our bitmask to get back what actually happened in the parsing -- particularly useful for error handling. This is will be done through [bit operations](https://github.com/JuliaData/Parsers.jl/blob/ab5ef1bbdc81fe8ee979a5b287ea065d991ba0ce/src/utils.jl#L44)
    - `vpos, vlen, tlen` where exactly our "parsing cursor" is at. This book keeping to know where to start parsing next.
5. TODO Error handling

So that's our basic building block for how to get started with Parsers.jl.

Now let's try and write the rest of the code to read a whole file that contains a single graph:

```julia-repl
function load_graph(file_name, ::Type{EdgeListFormat}) # The funky second argument is so that we filter for EdgeListFormat behavior, not important here.
    # yay code
end
```



