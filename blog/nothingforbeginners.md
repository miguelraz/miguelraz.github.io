@def title = "Julia's nothing, missing and NaN - a simple mental model"
@def author = "Miguel Raz Guzmán Macedo"
@def tags = ["missing", "nothing", "NaN"]
@def rss = "An intuitive explanation of nothing, missing, and NaN"
@def rss_pubdate = Date(2022, 02, 26)
@def published = "26 February 2021"
@def rss_guid = 5


A quick note for my Julia peeps to grok the difference between `NaN`, `missing` and `nothing` in JuliaLang. I have a few friends on twitter that remind me that the distinction between these concepts is not trivial, but I think I have a good mental model of how to address it and I might as well write it up. Hat tip to [Jasmine Hughes](https://twitter.com/Jas_Hughes/status/1494020182171275266?s=20&t=X6bd-uWW4b2CMW5xFzctUw) for inspiring this post and also [sponsoring me on GitHub so I can continue my open source campaing](https://github.com/sponsors/miguelraz/).

### A rainy setup

You are running a science experiment where you must measure the amount of rainwater that falls in a given day. The scientific-est thing your advisor has recommend is to setup a RainWater-O-Tron 9000 that collects data every day on how much water fell into a tube that sticks on top of it and reports it back the total at the end of the day.
Once the thing is plugged, your machine graciously spits into your data pipeline tool a table that looks something like this:

| Days | Rain [cm] | Status |
|---|:---:|---|
| 1 | 15  |OK|
| 2 | 20  |OK|
| 3 | 10  |OK|

So far, nothing out of the ordinary. Another humble data gathering expedition to appease the fickle gods of science and grants. The machine kindly records the centimeters of rain collected and its operating status - seems sensible.

You reset the machine and leave for Easter break and leave the robot running for a week, ready to come back and do some proper Science TM once you get the data back.

Ominously, you find the report to say this:

| Days | Rain [cm] | Status |
|---|:---:|---|
| 1 | 12  | OK |
| 2 | 22  | OK |
| 3 | 13  | OK |
| 4 |     | OK |
| 5 |     | NO |
| 6 | 💩  | OK |
| 7 | 18  | OK |

Clearly something has gone wrong, on days 4-6, but if you think about it carefuly for a second, the `Status` of each data point gives you some insight into *where* your data collection *could* have gone wrong.
* Days 1-3 went (likely) as expected
* Day 4 the RainWater-O-Tron recorded it *was* functional, but you didn't receive the data. You thus know the data for Day 4 is `missing`.
* Day 5 the machine wasn't even functional, and thus no data was collected, which means you have `nothing` as a data entry.
* Day 6 the machine *did* record data, but it got garbled somehow, and the result you got is `Not a Number`/`NaN`.
* Day 7 it seems the machine resumed normal operations.

This is the big distinction in how *much* you know about your data, and the "failure modes" of how it was mis/collected: you get an idea for how to approach its shortcomings based on what you recorded.
- for the `missing` data, perhaps the machine ran out of memory from the moment it made the water measurement accurately, but didn't transmit it, or the cable got bitten by some rats and thus you couldn't receive it
- the `nothing` data means that perhaps there was a power outage, and your entire apparatus was offline
- `NaN` means the internal functioning of the machine got compromised, or something in your calculations is wildly wrong

Of course, these are just narratives for illustrative purposes, but hopefully it can help solidify the distinctions and how these can help you think to solve your problem. Does that mean you must always use these sentinel values in your code or data collection? Not necessarily, but that's for you to decide if these are the right tools.

'Til next time.

