@def title = "Publications/Talks/Videos"
@def hascode = true
@def rss = "Publication feed for Miguel Raz"
@def rss_title = "PublicationsMiguelRaz"
@def rss_pubdate = Date(2019, 5, 1)

@def tags = ["talks", "videos", "publications"]

# More goodies

\toc

## More markdown support

The Julia Markdown parser in Julia's stdlib is not exactly complete and Franklin strives to bring useful extensions that are either defined in standard specs such as Common Mark or that just seem like useful extensions.

* indirect references for instance [like so]

[like so]: http://existentialcomics.com/

or also for images

![][some image]

some people find that useful as it allows referring multiple times to the same link for instance.

[some image]: https://upload.wikimedia.org/wikipedia/commons/9/90/Krul.svg

* un-qualified code blocks and indented code blocks are allowed and are julia by default

    a = 1
    b = a+1

or

```
a = 1
b = a+1
```

you can specify the default language with `@def lang = "julia"`.
If you actually want a "plain" code block, qualify it as `plaintext` like

```plaintext
so this is plain-text stuff.
```

## A bit more highlighting

Extension of highlighting for `pkg` an `shell` mode in Julia:

```julia-repl
(v1.4) pkg> add Franklin
shell> blah
julia> 1+1
(Sandbox) pkg> resolve
```

