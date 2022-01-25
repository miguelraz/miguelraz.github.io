function hfun_bar(vname)
  val = Meta.parse(vname[1])
  return round(sqrt(val), digits=2)
end

function hfun_m1fill(vname)
  var = vname[1]
  return pagevar("index", var)
end


function lx_baz(com, _)
  # keep this first line
  brace_content = Franklin.content(com.braces[1]) # input string
  # do whatever you want here
  return uppercase(brace_content)
end

function hfun_recentblogposts()
    list = readdir("blog")
	  filter!(f -> endswith(f, ".md") && !startswith(f, "index"), list)
    dates = [stat(joinpath("blog", f)).mtime for f in list]
    perm = sortperm(dates, rev=true)
    idxs = perm[1:length(perm)]
    io = IOBuffer()
    write(io, "<ul>")
	  # for (k, i) in enumerate(idxs)
    @sync for i in 1:length(list)
        if list[i] == "index.md"
            continue
        end

		    fi = "/blog/" * splitext(list[i])[1] * "/"
        @show fi
        title = pagevar("blog/" * list[i] * ".md", "title")
        @show title
        # title =  occursin("WIP", title) ? "🕵🏻 Shhhh... secret 🕵🏻 " : title
		    write(io, """<li><a href="$fi">$(pagevar("blog/" * list[i], "title"))</a></li>\n""")
		    # write(io, """<li><a href="$fi"> $(title) </a></li>\n""")
    end
    write(io, "</ul>")
    return String(take!(io))
end
