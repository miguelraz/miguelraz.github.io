@def title = "Julia parallel patterns cheatsheet"

With atomics landing soon in Julia, and parallel projects taking off, the time seems ripe to post about different parallel programming paradigms and how Julia can help you achieve them.
This post is geared towards people who feel already somewhat comfortable in Julia, but you don't need to be a seasoned dev to read it. The aim is to explain (to myself) and others what tools for speeding up your code are available if you want to parallelize.

### Concurency vs Parallel vs Distributed vs Multicore vs ...
Your machine vs many other machines

Does this work depend on other things?



- Async file download from different sites
- Map the function to all the elements in an array
  - function is cheap
  - funcition is expensive
  
- 
