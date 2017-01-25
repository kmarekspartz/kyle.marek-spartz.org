---
title: The (Linguistics) Pragmatic Programmer
mathjax: true
tags: linguistics, programming-languages
description: Applying principles of natural language linguistics to programming languages
---

*What follows is an mildly revised version of a final paper from the linguistics pragmatics course I took last spring.*


Programming language theory and theoretical linguistics are two fields
with overlapping histories. However, most programming languages are
not designed to behave like natural language. This post identifies
research in the pragmatics of natural language for programming
language theory researchers to adapt to programming language theory,
and vice versa.


### Code is for people

To effectively synthesize these fields, we need to remember that
programming languages are for people and not computers. People need to
be able to effectively convey ideas in programming languages, as well
as effectively understand ideas in programming languages.

A common example of this is when a programmer is working on a team,
other people will look at the code and need to understand it in order
to know how to use it. A less common example, though just as
important, is the diachronic situation: after a long period of time
the programmer returns to the code they wrote. They need to be able to
understand what they previously wrote. Since this is the case,
[Grice](http://ling.umd.edu/~alxndrw/Readings/Implicature/grice75.pdf)'s cooperative principle applies.

On the other hand, the language is restricted in that it needs to be
convertible into language for the computer to understand and evaluate
efficiently. This limits the kind of grammars and the flexibility of
the language designer, but does not prevent pragmatics from appearing
in the design.

Each of the Gricean maxims can apply to programming languages:

- *Quality:* The code should work (in most cases). This is usually an
  assumption.
- *Quantity:* Do not write too much (or too little). If too much is
  written, it wastes the computer's and more importantly the
  programmer's time. If too little is written (as in the `sed`
  programming language and 'one-liners'), the intent and function of
  the code is unclear.
- *Relevance:* Do not write unnecessary things. Code that is not
  needed for the intent of the program should not be included in the
  program.
- *Manner:* Do not obfuscate. This could be as simple as unclear
  variable names, or as complex as using obscure syntactic forms.

[The Pragmatic Programmer](http://pragprog.com/book/tpp/the-pragmatic-programmer) applies pragmatism (not pragmatics) to the
workplace structure of a software engineer, so it would not seem as
related as its title suggests. However, it does provide some tips to
consider when designing and writing software. These tips can be cast
in the frame of the Gricean maxims.

One tip is the DRY principle. DRY stands for 'Don't Repeat
Yourself'. This corresponds to *Quantity,* since a lack of repetition
results in a shorter program, but also to *Manner* since repetitive
software could be unclear to subsequent programmers using the program.

Another way of thinking about *Quantity* and *Manner* is in terms of
efficiency. In programming, we can think of efficiency in a number of
ways: code complexity, time complexity, space complexity. These
correspond to the engineering idiom "Good, Fast, or Cheap: Choose
two!"

Another tip from The Pragmatic Programmer suggests the separation of
concerns. This principle states that each section of code should
only handle one concern. Intuitively, this corresponds to *Relevance*.

*Quality* is a harder maxim to identify since programs are generally
considered to be correct if they run correctly. Some programming
languages make more or less claims about their correctness. This seems
to be the most highly weighted maxim for programming languages; the
others can be flouted to satisfy *Quality*.


### Determiners

Most programming languages do not have a notion of determiners. For
example, even in object-oriented languages where the class or prototype
of an object is also an object, we cannot use a determiner with the
class or prototype of the object to get an instance of that class or
prototype. However, an analogy of determiners and adjectives can be
made to database query languages and to object-relational mapping,
which provides a bijective map of objects and rows in a relational
database.

Lets consider the indefinite noun phrase, "a big red dog". In SQL, a
database query language, this can be expressed as:

~~~~{.sql}
SELECT FIRST(*) FROM Dogs WHERE color='red' AND size='big';
~~~~

The semantics of this statement are similar to the English. In SQL,
there are Tables and Rows. Tables correspond to the general noun,
e.g. dog, whereas Rows correspond to an individual. This statement
just gets some row from the table where the adjectives specified are
satisfied.

For definite determiners, such as "the big red dog", we want to make
sure there is only one result which satisfies those conditions. In SQL
this can be expressed as:

~~~~{.sql}
SELECT a FROM
(SELECT * FROM Dogs WHERE color='red' AND size='big') a
WHERE COUNT(a)=1;
~~~~

Note that this is purely a semantic translation into SQL. What if
there exists other big red dogs, but we can infer from context which
big red dog was being referred to? Pragmatic reasoning should improve
the result. This should be possible in a programming language. If you
only have one member of a class with those properties *in the current
namespace*, then that should be what is referred to, and if there
isn't one, check the next highest namespace. This is approximately how
natural language works.

There is a slight wrinkle in this suggest, but it can be resolved
consistently. When I said "a big red dog" did it create a new object
with those properties or utilize an existing big red dog? If it
created a new object, then later when I say "the big red dog" it
refers back to that same object. However, if it utilized an existing
big red dog (or if if failed to point to anything), then "the big red
dog" escapes out of the current namespace and looks around trying to
find somewhere else to provide an object to refer to. If we were
walking outside, it might be to some dog we see, but there is also
certain background knowledge in deeper namespaces which come in handy
even when there is no local referent. For example, with "the big red
dog", you may think of Clifford, the big red dog. This would be
pragmatic reasoning, and would be implementable into a programming
language.


### Anaphora

Some programming languages make use of anaphoric lexemes. However, the
use of anaphora in such languages is very limited. This section explores
current anaphoric structures in programming languages.

<!-- binding theory -->

#### Anaphoric lambdas

Anaphoric lambdas are used to create recursive anonymous functions
([Let Over Lambda](http://www.letoverlambda.com/), Chapter 6). Lambda expressions are used as anonymous
functions in many programming languages, but it is difficult to
represent recursive functions anonymously.

Consider the following. We would like to represent the factorial
function anonymously. Recall that $n! = n * n - 1 * ... * 2 * 1$. So
we write $\lambda n . n * n - 1 * ... * 2 * 1$. However, this would
not work, since the ellipsis represents recursion. Instead, we provide
an anaphor `self` which can be used within the lambda expression to
represent recursive calls to itself. With this in mind, we can write
the following anonymous recursive function:

$$factorial = \lambda n . \left\lbrace
\begin{array}{c c}
n & \textrm{if $n = 1$} \\
n * self (n-1) & \textrm{if $n > 1$}
\end{array}\right.
$$

Another use of `self` (or `this`) occurs when you want to refer to the
object wrapping the current namespace. For example, when defining a
class in Python, you use self to refer to the eventual instance of
the class:

~~~~{.python}
class Dog:
    size = string()
    color = string()
    name = string()
    owner = Person()
    location = Location()

    def run_to(self, object):
        self.location = object.location

    def fetch(self, stick):
        self.run_to(stick)
        self.run_to(owner)
~~~~

In other languages, the `self` in the methods would refer to the
methods themselves, rather than the instance object of the class. This
is more common in prototypal object-oriented languages (as opposite to
classic), due to how prototypes work For example, JavaScript, which
uses `this` in place of self, has this issue. As a work around to this
(no pun intended), a common idiom is to create a `that` variable which
refers to the object above the current one. In Python syntax, but
JavaScript scoping:

~~~~{.python}
def a(x):
   that = this
   def b(y):
       print( this === a )  # false!

       # inside b, `this` points to b, not a
       print( this === b )  # true

       # but `that` points to a!
       print( that === a )  # true
~~~~

The last notion of anaphor considered here is called cascade,
or method chain. Originally implemented in Smalltalk, cascade allows for programming language
constructions similar to "the owner threw the stick, told the dog to
fetch it, and watched the dog". Here is that sentence translated into
Smalltalk:

~~~~{.squeak}
[EmilyElizabeth threw: stick
                tell: clifford to: fetch the: stick
                watch: clifford]
~~~~

Cascade is implemented by returning the object (`EmilyElizabeth`, in
our case) from each method (hence 'method chaining'), rather than some
some other object or an attribute of the object. This may be more
readily understood in a more mainstream syntax:

~~~~{.javascript}
EmilyElizabeth.threw(stick)
              .tell(Clifford, fetch, stick)
              .watch(Clifford)
~~~~


### Hoare triples and presupposition

Another analogy can be made between Hoare triples and presupposition.
Hoare [proposed](http://dl.acm.org/citation.cfm?id=363259) a method of verifying program correctness using the following:

- Pre-condition (Set of possible states)
- Statement(s)
- Post-condition (Set of possible states)

To use Hoare triples, one specifies the expected post-condition for
the program and works backward through each statement to find the
needed precondition for the program. Each statement influences the
conditions by changing the set of states, for example, by
assignment. In an assignment statement, everything that previously was
true about the right hand side of the assignment is now true about
both the right hand side and the left hand side of the assignment.

The pre-conditions are similar to presupposition. This later
influenced the dynamic semantics approach to presupposition.


### Type inference

In programming languages, typing is controversial, with some
preferring strong static typing for reliability and efficiency, with
others preferring weak dynamic typing for its flexibility.

However, ignoring the social aspects, we may still be able to find a
natural language analogy to [type inference](https://en.wikipedia.org/wiki/Type_inference). Type inference allows the
computer to infer certain properties about the various objects under
consideration. For example, consider the following subset[^1] of Haskell:

[^1]: This is not actual Haskell, particularly the `+` operator. I
      simplified the language for the sake of demonstrating inference,
      but the principles apply to the larger language, too.

~~~~{.haskell}
x = 3
~~~~

We would like to assign each entity a type. We find `x` and we cannot
give it a type. We find `3` and we know it is an integer. Then we can
assign `x` to be an integer, since it is declared to refer to `3`.

~~~~{.haskell}
inc a = a + 1
~~~~

Here, there are more things that we need to infer. We see `inc` takes
an argument, so we know it must be of a function type, with some input
type and some result type. We see `a` and we know that it must be the
same as the input type of `inc`, but we cannot do anything else
yet. We see `1` and know it is an integer. We see `+` and know that
plus takes two integers and that it takes in `a`, so `a` must be of
type integer, and `inc` must take in and return integers.

~~~~{.haskell}
g f i = (f i) + 1
~~~~

Here, we see `g` and see that it takes two arguments, so it must be a
function that takes some argument and returns another function which
takes another argument and returns a result. We see `f` and `i` and
unify them with the respective arguments in the type of `g`, but
cannot do anything else yet. We see `(f i)` and know that `f` must be
a function from the type of `i` to some other type. We then see the
`1` and know that it is an integer. We then see the `+` and know that
it takes two integers and returns an integer. Then we know the return
type of `f` is integer, and the return type of `g` is integer. In
summary: `g :: (a -> Integer) -> a -> Integer` where `a` is a
polymorphic type corresponding to `i`.

This analysis can be done either during compilation (static) or at
runtime (dynamic). Static type inference is similar to what the
speaker of natural language does in sentence formation using
semantics. Dynamic type inference (for example, duck typing) is
similar to what the hearer does using pragmatic inference.

### Contracts

[Contracts](https://en.wikipedia.org/wiki/Design_by_contract), an extension to type theory inspired by Hoare triples,
provide additional means of software verification. Contracts are typically used to verify the pre-
and post-conditions of a function by either runtime checking the
arguments and results, or statically unifying the contracts of the
various functions and their calling conditions. For a long time,
this was difficult to do in languages with first class functions,
since there would be a recursive check with no base
case. [Findler, et al.](https://dl.acm.org/citation.cfm?id=581484) figured out how to include the base case,
and extends contracts with the notion of higher-order contracts.

Instead of typing variables, contracts provide limitations to the
properties of the variables. We can use the correspondence between
Sets and Boolean functions to efficiently represent and check these
conditions: Since conditions are just sets of possible states, each
contract can be takes a state and returns boolean value as to whether
it is in the set or not.

Contracts therefore must have the contract `Any -> Boolean`. The `Any`
is where the base case comes in. Since `Any` is a contract, it also
has the contract `Any -> Boolean`, but `Any` is defined to always
return true, so when checking the contracts of contracts, it ends up here.

There is also a `None` contract which always returns false, but it is
of little practical use.

There are also contract combinators, which correspond to the Set
and Boolean combinators. For example, the contract `-2 or Positive`
takes the -2 contract which checks for equality with -2, and the
Positive contract which checks for a positive number, and unifies them
into a composite contract. This is equivalent to the set union or
boolean or operators.

These contract combinators along with a minimization function may
provide a form of pragmatic reasoning for programming languages. A
minimization function would take these contracts and simplify
them. For example, `Number and Integer` simplifies to `Integer` since
anything in `Integer` is also in `Number`.


### Static and dynamic binding

In programming languages, scope refers to the method of resolving
variables to values. The two primary methods are dynamic and static scope.

Both scope methods have a stack of namespaces, with a new one for each
block. If the variable is not found in the current namespace, the
variable is searched for up the stack. However, where they differ is
the searching method. Dynamic scope uses a single namespace for
variables, and thus searches through each activation record on the
stack. Static scope only examines activation records which are deeper
than the first occurrence of the namespace for that block.

There does not seem to be much of a difference at first glance, but
the implications are numerous. Static scope is unintuitive to
implement, but intuitive to use, understand, and reason about within a
programming language, and thus very few programming languages use
dynamic scope.

This notion of scope is similar to the admittance of
[Karttunen](http://link.springer.com/article/10.1007%2FBF00351935), and later dynamic semantics approaches. Perhaps
the typology of programming languages can be used to inform our
understanding of name resolution in natural language.
