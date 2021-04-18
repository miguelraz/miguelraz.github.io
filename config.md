<!--
Add here global page variables to use throughout your
website.
The website_* must be defined for the RSS to work
-->
# RSS stuff
@def author = "Miguel Raz Guzmán Macedo"
@def generate_rss = true
@def website_title = "PathToPerformance"
@def website_descr = "A virtual diary for progress on all fronts by Miguel Raz Guzmán Macedo"
@def website_url = "https://miguelraz.github.io"

<!--
@def mintoclevel = 2
@def rss = ""
@def rss_description = "A blog about Julia and numerical relativity."
@def rss_title = "PathToPerformance"
@def rss_author = "Miguel Raz Guzmán Macedo"
@def rss_category = ""
@def rss_comments = ""
@def rss_enclosure = ""
@def rss_pubdate = ""
-->

<!--
Add here files or directories that should be ignored by Franklin, otherwise
these files might be copied and, if markdown, processed by Franklin which
you might not want. Indicate directories by ending the name with a `/`.
-->
@def ignore = ["node_modules/", "franklin", "franklin.pub"]

<!--
Add here global latex commands to use throughout your
pages. It can be math commands but does not need to be.
For instance:
* \newcommand{\phrase}{This is a long phrase to copy.}
-->
\newcommand{\R}{\mathbb R}
\newcommand{\scal}[1]{\langle #1 \rangle}
