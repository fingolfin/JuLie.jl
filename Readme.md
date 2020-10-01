# Combinatorics.jl

## About

This is (hopefully, eventually, some day) going to be a combinatorics package for [Julia](https://julialang.org)/[OSCAR](https://oscar.computeralgebra.de). The goal is to provide very efficient algorithms in combinatorics, especially for things relevant in representation theory. 

Why would anyone want to do this, especially when there is so much combinatorics already in other computer algebra systems? Well, on the one hand, it's a great way to learn about algorithms, so why not? On the more serious side, have a look at the following examples creating the list (not an iterator) of all [partitions](https://en.wikipedia.org/wiki/Partition_(number_theory)) of the integer 90 (there are ~56.6 million) in different systems.

In **[Sage](https://www.sagemath.org)** (v9.1):

```
sage: time X=Partitions(90).list()
Wall time: 3min 5s 
#Uses 26.665GiB mem, quitting Sage takes quite a bit of time
```

In **[GAP](https://www.gap-system.org)** (v4.11.0):

```
gap> L:=Partitions(90);; time/1000.0;
51.962 
#Uses 11.8477 GiB mem
```

In **[Magma](http://magma.maths.usyd.edu.au/magma/)** (v2.25-5):

```
> time X:=Partitions(90);
Time: 32.990 
//Uses 15.688 GiB mem, Magma UNUSABLE from now on!!
```

And now, in **[Julia](https://julialang.org)** (v1.5.2, my implementation):

```
julia> @time partitions(90);
5.447290 seconds (56.63 M allocations: 6.239 GiB, 46.77% gc time) 
#No problem afterwards
```

In the last one I'm cheating a bit because I'm using 8-bit integers (thus saving memory). But even when using big integers, the Julia implementation is more efficient:

```
julia> @time partitions(90); #this time with big integers (fmpz)
23.333262 seconds (156.37 M allocations: 15.056 GiB, 47.95% gc time)
#No problem
```

And having the possibility to also work with special integer types is very useful sometimes. Of course, you can do the same in C. But Julia is a high-level language with a similar simple syntax like Python, so why would anyone still go through such a pain?

**Note.** There is a [Combinatorics.jl](https://github.com/JuliaMath/Combinatorics.jl) already but this here is planned to go much farther (some day)—and I want to do it myself.

## Using

To install the package, do the following In Julia:

```
using Pkg
Pkg.add(url="https://github.com/ulthiel/Combinatorics.jl")
```

Then you can start using the package as follows:

```
using Combinatorics
partitions(10)
```

You can get a list of exported functions using

```
names(Combinatorics)
```

You can get help for a function by putting a question mark in front, e.g.

```
?partitions
```

## Developing

### Setting up the repository

Clone this repository to somewhere on your computer:

```
git clone https://github.com/ulthiel/Combinatorics.jl
```

Enter the directory "Combinatorics.jl", start Julia, hit the "]" key to enter REPL mode, and then add the package to the registry:

```
dev .
```

Exit the REPL mode by hitting the backspace key. Then you can start using the package as usual with

```
using Combinatorics
```

Any changes you make to the code now will not be available in the current Julia session—you have to restart it. This is simply the way Julia works but this is annoying when developing. A solution is to load the [Revise](https://timholy.github.io/Revise.jl/v0.6/) package before loading the package.

```
using Pkg
Pkg.add("Revise")
using Revise
using Combinatorics
```

Now, changes you make in the code are immediately available in the Julia session (except for changes to structures, here you need to restart).

### Programming guidelines

1. Have a look at the file src/part.jl to see how the stuff works and how I want code to look like.
2. Check out the [Julia Style Guide](https://docs.julialang.org/en/v1/manual/style-guide/).
3. Everything has to be well-documented, algorithms and papers have to be properly referenced.
4. If your implementation is not more efficient than those in other computer algebra systems then it's not good enough.
5. For every function you implement, there has to be a reasonable test in test/runtests.jl. You can run the complete unit test with ```Pkg.test("Combinatorics")```.