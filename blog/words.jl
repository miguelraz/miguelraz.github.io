### Script to find weasel words, passive voice and other crappy writing styles
using Test
weasels=r"many|various|very|fairly|several|extremely|exceedingly|quite|remarkably|few|surprisingly|mostly|largely|huge|tiny|((are|is) a number)|excellent|interestingly|significantly|substantially|clearly|vast|relatively|completely";
# Salte and pepper
r = match(weasels, " It is quite difficult to find untainted samples.")
@test r.match == "quite"
r = match(weasels, "We used various methods to isolate four samples")
@test r.match == "various"

# Beholder words ---- To our surprise, false positives were low (3%).
r = match(weasels, "False positives were surprisingly low")
@test r.match == "surprisingly"

# Lazy words
r = match(weasels, "There is a very close match between the two semantics.")
@test r.match == "very"

# Adverbs
r = match(weasels, "We offer a completely different formulation of CFA.")
@test r.match == "completely"


### Finding passive voice
irregulars = r"awoken|been|born|beat|become|begun|bent|beset|bet|bid|bidden|bound|bitten|bled|blown|broken|bred|brought|broadcast|built|burnt|burst|bought|cast|caught|chosen|clung|come|cost|crept|cut|dealt|dug|dived|done|drawn|dreamt|driven|drunk|eaten|fallen|fed|felt|fought|found|fit|fled|flung|flown|forbidden|forgotten|foregone|forgiven|forsaken|frozen|gotten|given|gone|ground|grown|hung|heard|hidden|hit|held|hurt|kept|knelt|knit|known|laid|led|leapt|learnt|left|lent|let|lain|lighted|lost|made|meant|met|misspelt|mistaken|mown|overcome|overdone|overtaken|overthrown|paid|pled|proven|put|quit|read|rid|ridden|rung|risen|run|sawn|said|seen|sought|sold|sent|set|sewn|shaken|shaven|shorn|shed|shone|shod|shot|shown|shrunk|shut|sung|sunk|sat|slept|slain|slid|slung|slit|smitten|sown|spoken|sped|spent|spilt|spun|spit|split|spread|sprung|stood|stolen|stuck|stung|stunk|stridden|struck|strung|striven|sworn|swept|swollen|swum|swung|taken|taught|torn|told|thought|thrived|thrown|thrust|trodden|understood|upheld|upset|woken|worn|woven|wed|wept|wound|won|withheld|withstood|wrung|written"

### verbs = Regex("\b(am|are|were|being|is|been|was|be)\b[ ]*(\w+ed|$irregulars)\b")
verbs = Regex("(am|are|were|being|is|been|was|be)\b[ ]*(\w+ed|($irregulars))")


y = match(verbs, "were added")

