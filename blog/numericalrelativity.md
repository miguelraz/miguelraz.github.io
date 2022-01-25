@def title = "WIP Julia and Numerical Relativity"
@def tags = ["Julia", "HPC", "Fortran", "numerical relativity", "pde"]
@def date_format = "10 April 2021"

### Where does Julia fit in the world of numerical relativity? A roadmap towards gravitational inclusion

### Why this post?

Well, at some point, you have to a) be comfortable with your ignorance and b) lay down a plan for future work. This aims to be both.

![Me, an absolute fool, banging on my drum](https://marcminter.files.wordpress.com/2017/03/luther-nailing-theses-560x538.jpg?w=560)


Usual caveat: I'm an undergrad newb and talk to an expert. I can't really speak as to what is the state of the art in the field and what the interesting directiosn are since I've not become an expert yet, but here's my 2 cents:

1. What is numerical relativity? Open question, but there's some broad areas of interest: gravitational waves (leaning more towards a DSP  / data analysis ecosystem. We can include here all the devils of massive scientific data pipeline management and the usual foes: python fronteds wrapping C codes), simulation (PDEs and massive parallelization, think clusters and MPI) and up and coming hybrid approaches for mitigating the simulation costs (surrogate models / ML applications)
2. What are the open problems? Stellar collapse (what does it actually look like before an object collapses in on itself due to sheer gravity?), binary mergers (What spectra do we expect to see from 2 colliding black holes? 2 neutron stars? etc

3. What are the current tools and limitations? Oooh boy. It's almost always C/C++/Fortran all the way down. Some brave people do surrogate modeling with python/numpy combos but it's rare. The cutting edge out there used to be the Einstein Toolkit, which had a notion of "nodes"/modular code reusage. i.e., you could include a module with a particular physical interaction (think some magnetohydrodynamic approximation / optimized method) and, with some dedication and a friendly sysadmin you could conceivably get to run it in your university cluster. The current "cutting edge" system today is the SXS collaboration where experts are a) married to the parallelism model of Charm++ and b) spending their precious time like reimplementing the newton method for their architecture and plotting capabilities.

4. Before that, most codes where just hoarded by research groups, and let's say that the open software practices stagnated with their comic sans webistes in 2003. Not kidding, there is very little, if any, of the "social aspect" of coding in the git/social way as we know it in the Julia community.

5. So what can Julia offer? Well, we're almost there yet. We need some solid tensorial algebra foundations to reduce to DiffEq + friends for some auto parallelization + sparsity detection. That's the long term plan, but as Chris said, it takes a village to solve a PDE. (Currently trying to implement the most basic symbolic tensor analysis frameworks, but it's a term project and we'll hope it pans out well :crossed_fingers::skin-tone-5: ) There is also unfortunately some roadblocks when it comes to the cluster management story - MPI is still not as fully Julian-ized an experience as it could be and we haven't had our robust buildup of distributed computing (we don't have a coherent MapReduce implementation). That being said, I'm still a diehard Julia fan and don't think that the people with the PhDs or Masters can compete with Julia's flexibility, composability and speed in the long run. It will be a long run though.

6. As for the specific aspect of numerical relativity that I'm interested in, we're still missing on some extensible differential geometry frameworks. Specifically, there's at least 2 popular formulations for Binary Black hole mergers - the ADM formulation, and the 3+1 formulation. 3+1 is what my school does (Since Miguel Alcubierre is it's proponent/evangelizer) and ADM is the one in the Shapiro book. They both have strengths and weaknesses, to my knowledge no system combines both of them. But Julia can just dispatch... 

7. Coming back to the gravitational waves:
The DSP pipeline is still missing. We don't have registered github packages for the GWOSC (Gravitation Waves Open Sources Collaboration) where you can query GW data and analyze it. the PyCBC wrappers could be rewritten in Julia and some Plot recipes added, not to mention the tutorials and documentation. Most of the DSP parts are there, but as bare building blocks - not as established "pre-cooked" routines. (Think our Flux stack vs sci-kit learn, sorta)
