---
title: Eventual consistency for SQL: Normalization
tags: databases
description: Using a log-structured schema, we can merge SQL databases to achieve eventual consistency.
---

*Previously, I
[introduced](http://kyle.marek-spartz.org/posts/2015-09-08-eventual-consistency-for-sql-databases.html)
eventual consistency for SQL. This post illustrates how to normalize an
eventually consistent SQL database.*

To demonstrate how to normalize for eventual consistency, let's design a
database for a Twitter clone, consisting of users and statuses. A traditional
schema for a Twitter looks like:

~~~ SQL
CREATE TABLE Users (
  username VARCHAR(255) PRIMARY KEY,
  email VARCHAR(255),
  phone VARCHAR(255),
  location VARCHAR(255),
  confirmed BOOLEAN NOT NULL,
  salt VARCHAR(255) NOT NULL,
  hashed_password VARCHAR(255) NOT NULL
);

CREATE TABLE Statuses (
  content VARCHAR(140) NOT NULL,
  created_at DATE DEFAULT ( SYSDATE ) NOT NULL,
  username VARCHAR(255) REFERENCES Users (username) NOT NULL,
) PRIMARY KEY (content, created_at, user_id);

CREATE TABLE Follows (
  follower_username VARCHAR(255) REFERENCES Users (username) NOT NULL,
  followee_username VARCHAR(255) REFERENCES Users (username) NOT NULL
) PRIMARY KEY (follower_username, followee_username);
~~~

The first step in normalizing for eventual consistency is to identify state
changes in your data. For example, a user becomes confirmed after clicking a
link in an email or text message. Under the schema above, the following
`UPDATE` statement would get executed:

~~~ SQL
UPDATE Users
SET confirmed = true
WHERE username = 'kmarekspartz';
~~~

However, since we're avoiding `UPDATE`, this will not work. Instead, let's
normalize this mutation out of our database.[^1]

[^1]: I'm going to assume offline migrations for simplicity, but these
migrations can be achieved in a zero-downtime environment, too. You would create
both places for the data reside, deploy a version of the application to read
from both, deploy a version of the application to write to both, run a backfill
migration (like in the example), then deploy a version which only reads and
writes the new place, then drop the old place. Fun!

~~~ SQL
CREATE TABLE Confirmations (
  username VARCHAR(255) REFERENCES Users (username) NOT NULL
);

INSERT INTO Confirmations
SELECT username
FROM Users
WHERE confirmed = true;

ALTER TABLE Users
DROP COLUMN confirmed;

INSERT INTO Confirmations VALUES ('kmarekspartz');

SELECT Users.*, IS_NULL(Confirmations.username) AS confirmed
FROM Users
LEFT OUTER JOIN Confirmations
ON Users.username = Confirmations.username;
~~~

Applying this normalization to the rest of the schema would lead to a new
schema:

~~~ SQL
CREATE TABLE Users (
  username VARCHAR(255) PRIMARY KEY,
  salt VARCHAR(255) NOT NULL,
  hashed_password VARCHAR(255) NOT NULL
);

CREATE TABLE Confirmations (
  username VARCHAR(255) REFERENCES Users (username) NOT NULL
);

CREATE TABLE Emails (
  email VARCHAR(255) PRIMARY KEY
);

CREATE TABLE UserEmails (
  username VARCHAR(255) REFERENCES Users (username) NOT NULL,
  email VARCHAR(255) REFERENCES Emails (email) NOT NULL
) PRIMARY KEY (username, email);

CREATE TABLE Phones (
  phone VARCHAR(255) PRIMARY KEY
);

CREATE TABLE UserPhones (
  username VARCHAR(255) REFERENCES Users (username) NOT NULL,
  phone VARCHAR(255) REFERENCES Phones (phone) NOT NULL
) PRIMARY KEY (username, phone);

CREATE TABLE Locations (
  location VARCHAR(255) PRIMARY KEY
);

CREATE TABLE UserLocations (
  user_location_id PRIMARY KEY AUTOINCREMENT
  username VARCHAR(255) REFERENCES Users (username) NOT NULL,
  location VARCHAR(255) REFERENCES Locations (location) NOT NULL
);

CREATE TABLE UserLocationDeletions (
  user_location_id REFERENCES UserLocations (user_location_id) NOT NULL
);

CREATE TABLE Statuses (
  content VARCHAR(140) NOT NULL,
  created_at DATE DEFAULT ( SYSDATE ) NOT NULL,
  username VARCHAR(255) REFERENCES Users (username) NOT NULL,
) PRIMARY KEY (content, created_at, user_id);

CREATE TABLE Follows (
  follow_id PRIMARY KEY AUTOINCREMENT,
  follower_username VARCHAR(255) REFERENCES Users (username) NOT NULL,
  followee_username VARCHAR(255) REFERENCES Users (username) NOT NULL
);

CREATE TABLE FollowDeletions (
  follow_id REFERENCES Follows (follow_id) NOT NULL
);
~~~

I've turned most properties into many-to-many relationships, and added deletion
tables for the join tables. This is because many-to-many relationships are
easier to merge than one-to-one. With a many-to-many, you can use `UNION` as
your merge strategy. With one-to-one, there's not a deterministic way to choose
a winner. This will result in temporary inconsistencies, but if you have each
user interact with a particular host or shard, you can minimize those
inconsistencies. In a mobile environment, the user is interacting with their
phone, and we can guarantee that their phone is in a consistent state at any
given time. In a server environment, we can route that user's interactions to a
particular host, failing over to an in sync replica if that host is down.

One thing that doesn't work well with a many-to-many relationship is passwords.
I left it as one-to-one, but passwords aren't needed anymore, particularly when
there is an email address or a phone number available. Instead of asking a user
for a password, we can send them a link with a token to sign in. This is
one-factor authentication, but uses what is commonly a second factor in
two-factor authentication. Removing passwords from this schema would make
eventual consistency possible.

---

I like to call this method of normalization 'log normalization' but that gets
[confusing](https://en.wikipedia.org/wiki/Log-normal_distribution). It is too
bad we have unique constraints on technical terms. If there's a better name for
this, let [me](mailto:kyle.marek.spartz@gmail.com) know!
