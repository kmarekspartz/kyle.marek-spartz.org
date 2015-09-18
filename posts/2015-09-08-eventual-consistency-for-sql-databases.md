---
title: Eventual consistency for SQL databases
tags: databases
description: Using a log-structured schema, we can merge SQL databases to achieve eventual consistency.
---

[Eventual consistency](https://en.wikipedia.org/wiki/Eventual_consistency) is
typically thought of as a property of certain NoSQL databases.  However, SQL
databases can achieve eventual consistency with adequate planning.

Eventual consistency is particularly useful for horizontally scaling web
services, as each node does not need the full, up to date picture. Another use
case is synchronizing mobile applications with intermittent network
connectivity. In both cases, partitioning or
[sharding](https://en.wikipedia.org/wiki/Shard_%28database_architecture%29)
allows each user or client to maintain a consistent view.

A data structure is considered eventually consistent if two instances can reach
a consistent state given the same unordered set of state changes. Two databases
are eventually consistent if all actions taken in one propagate to the other.

Strong eventual consistency can be achieved if state changes are
[commutative](https://en.wikipedia.org/wiki/Commutative_property),
[associative](https://en.wikipedia.org/wiki/Associative_property), and
[idempotent](https://en.wikipedia.org/wiki/Idempotence).

State changes are commutative if swapping two operations yields the same state.
For example, these two operations can apply in either order to yield a
logically equivalent table:

~~~ SQL
INSERT INTO some_table (some_column) VALUES (1);
INSERT INTO some_table (some_column) VALUES (2);
~~~

Similarly, state changes are associative if three operations can be paired
either way yielding the same state. For example, three databases each with one
of the following operations can be merged as (1 + 2) + 3 or 1 + (2 + 3) to yield
a logically equivalent table:

~~~ SQL
INSERT INTO some_table (some_column) VALUES (1);
INSERT INTO some_table (some_column) VALUES (2);
INSERT INTO some_table (some_column) VALUES (3);
~~~

Not all [SQL DML](https://en.wikipedia.org/wiki/Data_manipulation_language) can
be commutative or associative:

~~~ SQL
UPDATE some_table SET a = 1;
UPDATE some_table SET a = 2;
UPDATE some_table SET a = 3;
~~~

Depending on the order of these operations, the resulting database would be in
different states.

`DELETE`s also cause problems. Given two databases, where one has ran a deletion
and one has not, merging them would re-insert the deleted row in the database
with the deletion:

~~~ SQL
DELETE FROM some_table WHERE some_column = 4;
~~~

We can limit DML to `SELECT`s and `INSERT`s to avoid using other synchronization
methods. Avoiding updates and deletes provides
[immutability](https://en.wikipedia.org/wiki/Immutable_object), which guarantees
a row will not change or disappear from our databases.

By staying `INSERT`-only, we treat our database as a [persistent data
structure](https://en.wikipedia.org/wiki/Persistent_data_structure), or an
append-only commit log.

Immutability and persistence helps with eventual consistency, but they are not
sufficient. We also need idempotence. State changes are idempotent if repeatedly
applying the same state change yields the same state. Our previous example,
`INSERT INTO some_table (some_column) VALUES (1)` is not idempotent, unless we
de-duplicate rows at query time:

~~~ SQL
SELECT DISTINCT some_column
FROM some_table;
~~~

Another way to achieve idempotence is to use a unique constraint to prevent
duplicates from being inserted and ignore unique constraint violations upon
insertion. We can also manually check for duplicates during an insert:

~~~ SQL
INSERT INTO some_table (some_column)
SELECT 4
WHERE NOT EXISTS (
  SELECT 1
  FROM some_table
  WHERE some_column = 4
);
~~~

How can we delete an item from our database without using SQL `DELETE`?
[Tombstones](https://en.wikipedia.org/wiki/Tombstone_%28data_store%29) provide
our answer. Instead of `DELETE`ing the row, we can create a marker in another
table that says an object is deleted.

~~~ SQL
INSERT INTO some_table_deletions (some_table_id)
VALUES (123456);
~~~

Queries for undeleted rows then become:

~~~ SQL
SELECT some_table.*
FROM some_table
WHERE id NOT IN (
  SELECT some_table_id
  FROM some_table_deletions
);
~~~

If we want to support deletion and re-adding of the same value, we cannot use a
unique constraint for idempotence since the unique constraint would prevent the
addition of the new row. Instead, either de-duplicate at query time using
`DISTINCT` or prevent duplicates from getting inserted without using a unique
constraint:

~~~ SQL
INSERT INTO some_table (some_column)
SELECT 4
WHERE NOT EXISTS (
  SELECT 1
  FROM some_table
  WHERE some_column = 4
  AND id NOT IN (
    SELECT some_table_id
    FROM some_table_deletions
  )
);
~~~

At this point it looks like we'll need to
[normalize](https://en.wikipedia.org/wiki/Database_normalization) our database,
or structure our data in a particular way in order to satisfy these properties.
In my next blog post, I'll demonstrate how to normalize a database to
achieve eventual consistency.
