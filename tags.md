@def title = "Menu 3"

# Working with tags

**Example**:

* page with tag [`tutorial`](/tag/tutorial/)
* page with tag [`numericalrelativity`](/tag/numericalrelativity/)

\toc

## Indicating tags

To mark a page with tags, add:

```markdown
@def tags = ["tag1", "tag2"]
```

then that page, along with all others that have the tag `tag1` will be listed at `/tag/tag1/`.

## Customising tag pages

You can change how a `/tag/...` page looks like by modifying the `_layout/tag.html`. An important note is that you can **only** use **global** page variables (defined in `config.md`).

There are three "exceptions":

1. you can still use `{{ispage /tag/tagname/}} ... {{end}}` (or `{{isnotpage ...}}`) to have a different layout depending on the tag,
1. you can use the `fd_tag` variable which contains the  name of the tag so `{{fill fd_tag}}` will input the tag string as is,
1. you can use `{{fill varname path/to/page}}` to exploit a page variable defined in a specific page.

## Customising tag lists

By default the tag list is very simple: it just collects all pages that match the tags and it shows them in a simple list by anti-chronological order (more recent at the top).

You can customise this by defining your own `hfun_custom_taglist` function in the `utils.jl` file. The commented blueprint for the simple default setting is below and should give you an idea of how to  write your own generator.
