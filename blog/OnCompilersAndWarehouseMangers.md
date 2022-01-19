@def title = "🚧 WIP: 🚧 Programs, Compilers, and Warehouse Managers"
@def author = "Miguel Raz Guzmán Macedo"
@def tags = ["compilers", "JIT"]
@def rss = "This blog is about trying to explain to non computer people what compilers do, and why JITs are cool and how they fit in that world view." 
#@def rss_pubdate = Date(2021, 05, 09)
#@def published = "09 May 2021"

### Reading time: 15 minutes
### Summary:
As a soon-to-be physicist, there's nothing I value more than a useful lie. A story that's simple, captivating, and a good builder for intuition that can last for years -- those are the lies that I like. I also like to code in the Julia programming language, and I get very excited talking about very intricate technical details to supportive friends and helpless victims. Not many of my friends and family are into computers, which means I have to come up with great ~~lies~~ stories to talk about compiler optimizations with other people. 

This is a story that I've told myself (and others) in order to make sense of what the hell a compiler is supposed to do in the best way I know how: by just *lying about it*, but in a plausibly-deniable, convenient sort of way, until I you can learn to measure otherwise. 

All imprecisions are my fault, but it is my hope that where I miss the mark, you get a working mental model of how some of these compiler things work. 

My **useful lie** for the rest of this post is that programs are plans to move boxes of bits around, not completely unlike a "warehouse manager" who must handle daily orders and boxes coming in and out of their warehouse, and that planning upfront or on the fly how to process the boxes is the key difference between compilers and interpreters.

That's *it*, that's my post. 

The rest of it is just narrative coloring, but the TL;DR is:

> If you think of programs as boxes of bits to be moved around inside a computer, you can plan ahead or do it on the fly. The ones that plan upfront are called **compilers** (in languages like C/Rust) and can come up with very efficient ways to move the boxes because they know the sizes of everything before hand and can plan accordingly (make optimizations). **Interpreters** (Python/R) delay planning and trade the convenience of having to plan with just using more storage space and not badgering clients with plans all the time. This means they mostly can't optimize better routes or shipments of the boxes because they don't know how much is coming in or when, but there's enough space to accommodate their needs (usually). **Speculating JITs** (Javascript) are interpreters that "bet" that frequent orders that have been made before will be made again, and so try to make a plan for those when enough identical orders are made. **Type-based JIT Compilers** (Julia) try to figure out the sizes of the boxes when they arrive with fancy tech (type inference algorithms/x-ray goggles to figure out what's inside the boxes) and then make a clearing plan like a compiler would. They rely on their fancy tech to work as expected (no lead linings in the boxes) and for the order not to be too urgent when they are doing the on-the-fly planning, but they get the compiler speed throughput when things work out.

It is my deep held conviction that compilers are explainable to curious children, if one is patient and willing to help the listener build the right [language for it](https://www.youtube.com/watch?v=_ahvzDzKdB0), though perhaps not yet by me. Guy Steele explained Operating Systems in monosyllables in the previous link, and [Sy Brand helped me understand monads with cats in under 2 minutes.](https://twitter.com/TartanLlama/status/1460608706048106501) -- or at least the gist of it, which is enough for me right now. Both of them are the inspiration for this post and worth your time, so here's my own hand in this endeavor.

----

**Note:**
There's a spoiler about all the technical terms at the end if you want to keep going down the rabbit hole, because I'm all about lowering all the gates and building all the bridges. And if you want to read oodles more, you can always [sponsor me on GitHub](https://github.com/sponsors/miguelraz/) to keep the blog rolling along.

---- 

### The warehouse: Meet the compilers

First day at the new gig.

It used to be a shoe strings factory, but they retrofitted the place to become the `Silly Cones Clearing Warehouse`. Right, you forgot they're terrible at naming things here. You pull up to the main entrance with your shiny name badge and you're hailed by a friendly supervisor who kindly gives you the run of the place. They're called Ash[^1], and they help everyone get setup and working with each other.

Your job description says you're a "compiler/interpreter". The supe says both are just moving boxes around with all sorts of bits in them, but your workload will vary widely based on your worksheet details and client specifications.

> There's basically two shift styles here - lemme show you how the old guard does it first.

You nod and follow them to meet the compiler crew.

You first met Cece[^2]. Everyone seems to have started training with Cece at some point, for better or for worse. Cece tells you that you're job is quite simple:

> Here's the gig kiddo: We have tons of client orders in-flight all the time. Their orders are shipping boxes, and they go through our warehouse centers. Some clients ask for small deliveries - like a toothbrush - and those fit in those smallest boxes in that register behind ya. There's not many of those but they're the easiest and closest. Once that order makes it into the van in the docking bay, you get them all back from the stack over there. Basic rule of thumb here: the closer the boxes, the smaller they are, but the faster you can reuse them. 

"So I'm moving knick-knacks all day? Just from our processing unit to the bay?"

> Huh, we wish. Those are the small fish. We also get orders for shipping containers that are getting backlogged all over the east coast nowadays - we have to accommodate them all.

"What?"

> Yeah, happens all day. Gigs of 'em.

"But shipping containers don't fit in these toothbrush boxes Cece."

> Well, that's why I always ask everyone upfront for the size of everything their sending. If they don't send me a form sheet, I just send it back. Oh right -- a form sheet means that everything the client wants to move through this warehouse must have a specified box size. If they can't write it down at the time, they must put it a special request with Mally. There's forms behind you to check that all the items actually fit in the boxes they say.

"You always do this manually?"

> It's worked for me, and it's good you start learning it too, it's as close to understanding how this warehouse works as you'll get. Just remember - at Silly Cones, if you ever need more boxes, we can always get more rackspace, you just need to make the paperwork. We have tons of space, but it's out of town, so your orders will be delayed while we move the stuff back and forth.

You sigh at the thought of filling all these forms for boxes by hand all the time, but it's lunch break already.

---

You spend a few weeks with Cece and you get good at what you do. Cece takes particular delight in packing the structures compactly and not wasting more boxes than what they deem necessary; such waste is the ultimate crime. 

You keep noticing however, that CeCe definitely fudges some of the form sheets - some boxes are just filled with the wrong name, names get overwritten, stuff spills out when it doesn't fit in the boxes the client asked for and then a few hours of everyone's time is wasted picking up the mess. Credit where it's due - some clients ask exclusively for CeCe and are used to his manual and error-prone ways, something about the devil they know...

Cece was also devilishly brief about what your assignment *actually* meant (Cece has a knack for understating complexity in your daily tasks). See, some of these boxes arrive empty but have a tracking code on the side, and so you have to go and find the box in the warehouse that that the tracking code is referring to, because that's where your items are actually stored. This is useful because you can get a warning that something is coming, but you don't know where it'll be, so you try your best and carry on at whims of the client's wishes.

On the happy days, you get a full detail sheet of all the concrete things you gotta haul, but boy when you have to chase boxes[^4] for everything and drag it around and rewrite the form sheet... it's not fun, or fast AND you have to go back and forth from the form sheets the client gave you and manage the tracking codes manually. Oh and if you miss putting back any of the empty boxes your wages get docked, just to add to the fun of the whole operation. And sometimes they change their mind as you're 3 tracking code trips into the order and you have to start again -- worst of all is when Cece jumps ahead of you and overwrites your order! You guess it's the price of admission into this gig and hunker on. At least the gig pays.

Ash has kept coming around and chatting with you, asking how the box shuffling is treating you and if you like working close to the metal. 

> Hey, you should come with me to bikeshed, there's a person you should meet.

You're on your lunch break and could use a break from stamping forms as `null` so you take Ash up.

Ash introduces you to Rusty[^3], also a part of the compilers team. He's fixing his bike chain and hasn't taken the helmet or high-visibility vest off.

> Nice to meet you! 👷 

He says. He asks about your last few weeks with Cece and groans reminiscing of all the manual paperwork.

> ... boy have I been there - I've told Cece a million times that's no way to live. If only he'd plan a little...

Rusty is very enthusiastic about workplace safety and definitely sounds like a fun guy. Rusty started out with Cece but got tired of all the potential accidents and mishaps on the main floor and had to come up with neat hacks for "never facing those problems again":

> It's like a hall pass system for the orders that are coming in - Only one person can hold the permission slip for the order boxes they're touching at the time. That way, no one can mess up anyone else's orders, because they can't access them in the first place!

Rusty has a smaller working space than Cece, and it takes him a bit longer to work through the form sheets with this added ownership slip system, but he says he never has to worry about all the crap that Cece is used to.

Your lunch break is over and you start scuttling back to your station as he mumbles something about "making errors unrepresentable" and [train emergency breaks](https://www.youtube.com/watch?v=A3AdN7U24iU) or something. Rusty talks **fast** and can't stop talking about trains in general. **Loves** them.

----

### Meet the interpreters

You've been clearing oodles of orders with the Rusty system for a few weeks now - you've seen almost no box spills since you started with the permission slip system but it seems worth it with the exacting clients Cece gets overwhelmed with, permission slip system and all. It's not like Rusty isn't demanding either - but he has a knack for colors and [proactive feedback that's a wholesome breath of fresh air](https://twitter.com/ekuber/status/1438178928984829959). (Colors! How come Cece always wrote all those forms with the same black fountain pen? Rusty at least uses playful stickers every now and then...)

Ash rolls around again. Ash gives you a glowing performance review but says you're not going to improve much if you don't learn from how other people work at the warehouse, and that your next rotation is with the "interpreter" camp. 

You both stroll to the docking bay where orders are received and Peter[^6] is waiting for you. They have a cool snake 🐍  tattoo on one arm and a Jolly Roger in the other ☠ . Peter seems to be living the good life - he's sitting at a desk filled with many walkie talkies and is reading the papers. 

You start chatting for a while and you learn that `Silly Cones` serves many more types of clients than what you have seen with Rusty or Cece:

> Most of these clients, if you send them back the form sheet, you won't hear from them again. That's why it's just best to receive all their orders here, unbox it in the docking bay and figure out what they need and call for backup if we don't have enough space.
 
"So what's with all the phones?"

> Well, I need to call loads of our network warehouses to check if they have the stuff - we don't have enough unboxing space in the docking bays here, so that's why I'm always calling other warehouses to see if they have the stuff that the tracking number is redirecting to.

"So most of your time you're just waiting for the boxes to arrive?"

> Yup! Or unboxing and chasing them around here. There might be some processing here but there's always breaks when things haven't arrived. Oh, and calling other places to see if the boxes are there too - sometimes finding it is the worst part, but that's why we have all these radios to call them.

Well this new lifestyle of luxurious time waste is new to you, but the clients are raving for the lazy approach that Petey provides. He even got a tattoo of `tang ping` across the knuckles but you're sure the bosses would've [seen it by now](https://www.nytimes.com/2021/07/03/world/asia/china-slackers-tangping.html). 
























[^1]: `Ash` is supposed to be `bash` the languages used to install stuff and compile/run programs from your terminal.
[^2]: `Cece` is supposed to be the `C` programming language, because in `make` scripts it's the name of the C compiler variable `CC=gcc` or something like that. His manual style of asking for all sizes upfront is indicative of a compiled programming language - They can be fast, and waste little space.
[^3]: `Rusty` - Rusty is supposed to be Rust, the programming language that trades compile time for the safety guarantees that an ownership system/hall pass system/mutually exclusive access gives.
[^4]: unboxing -  
[^5]:
[^6]: Peter is supposed to be Python and R, the interpreted languages (worst pun joined name ever).
[^7]:
[^8]:
[^9]:

===== (I think I will cut...)
> Programs must plan how to execute instructions, which means they must process boxes of different sizes of bits. If programs are boxes of bits moving through a clearing warehouse, there's two large camps that people fall into to make these plans: compilers and interpreters. Compilers ask for form sheets of all the boxes the clients ordered to be submitted upfront so they can plan better (and have orders/programs cleared faster). This is tedious because you have to worry about where and how all the things are stored and you have (often) fill these orders manually. Fortunately, the warehouse has tons of containers they can setup for you to use - register boxes are fast and small, and out of town warehouses can store cargo containers worth of stuff, but it will take orders of magnitude more time to fetch things back and forth. This is why it's useful to have the form sheets ahead of time: You can cut down on unnecessary trips (which will save time) and you can calculate your box measurements.

> Interpreters however, take a different approach - They bank on this incredible trove of available out-of-town warehouses that can fetch boxes as they need them. They've also evolved a strategy to be as lazy as possible: their clients usually don't have the time to prepare form sheets for their orders, so it's not worth worrying about. Instead, they have their clients always send boxes with addresses to other boxes - they must always open to boxes to figure out what is inside and where it's stored. They gain a lot of flexibility, but they trade it off for not being able to plan ahead with the order forms, and most of their time is wasted chasing down boxes in different warehouses and accounting for not losing any of them.

> These interpreters figured out they could probably do better and so 2 new strategies arose - the gamblers and the techies. The gambling interpreters figured that almost every monday at 7am, the same order by the same clients came along. So when they started seeing the same orders come in too many times, they tried to plan ahead to "fast track" those boxes to be cleared through the warehouse without looking inside the boxes. Sometimes they get it wrong (like any speculation), and they have to fall back on the lazy style of unboxing, but they can clear a lot of order flows surprisingly quickly. The techies however went for a hybrid approach - they had to nerd out and create some really fancy X-Ray goggles to find what's inside the boxes when the arrive (like the interpreters) but then fill out order forms and plan accordingly once they know the sizes and save it in a special file cabinet. When the same order rolls around again, they can execute like the compilers. 

==== (... all of this)
