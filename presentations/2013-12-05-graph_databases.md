% Graph Databases
% Kyle Marek-Spartz
% December 5, 2013

# Traditional Relational Databases

- Rows (and Tables)
- 'statically typed'
- structs and pointers
- need an ORM
- `.*SQL.*`


# Document Databases (key/value stores)

- Documents
- 'dynamically typed'
     - schema free
- dynamic structs (and pointers)
- still relational
- still needs an ORM
- `((Mongo|Couch)DB|Redis)`


# Graph Databases

- Nodes and Edges
- Either 'static' or 'dynamic' typing
    - though typically 'dynamically typed'
- Objects!
- `Neo4j|ArangoDB|Titan`


# Querying Graphs

- No matter how the data is being stored, you may have a dataset shaped like a graph:
	- (buzzword alert) Social Networks
	- Insurance applications
	- Threading Emails (See [jwz's algorithm](http://www.jwz.org/doc/threading.html))

# Querying Graphs *Efficiently*

- Don't use SQL!
    - joins are inefficient
    - and hard to read
    - and hard to reason about
- jwz is (or at least was) anti-database
    - if your emails are in the filesystem, just use the filesystem
    - efficient
    - if you are a good C programmer
    	- (dmr > jwz > rms)
    	- (though jwz doesn't have a beard.)
    - if your filesystem can handle each node

# Querying Graphs *using a DSL*

- What if our query language had a notion of nodes and edges?
- DSL for querying


# Representing Relationships

(Not in SQL or Cypher, these are just to get the point across)

- `SELECT * WHERE user -[ Borrowed ]-> book`
- `SELECT borrowing WHERE user -[ borrowing:Borrowed ]-> book`
- `SELECT * WHERE lending -[ To ]-> user && lending -[ Of ]-> book && lending -[ At ]-> date`


# Database Migrations

- Let the data dictate the structure of our database.
- Don't determine the structure and squeezing the data in.
- Migrations become much easier.
- (Similar to the benefits of dynamic languages)


# The Book

![Graph Databases Book](/images/graph_databases_cover.png)

- [www.graphdatabases.com](http://www.graphdatabases.com)
- free ebook version
- ~$25 print version
- describes core principles of graph databases
- focuses on Neo4j, but discusses others

# See also:


See also: [bulbflow](http://bulbflow.com/)
