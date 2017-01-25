---
title: RESTful Email
tags: ideas, email
description: A proposed REST API for email
---

There are a few different options for Email REST APIs, but none of them, as far
as I can tell, are a replacement for the traditional email protocols, SMTP,
POP, and IMAP. What would such a system look like?

First, instead of our usual email addresses, we'd have routes, so my email,
<kyle.marek.spartz@gmail.com>, would look more like:

    gmail.com/kyle.marek.spartz

To GET all of my mail:

    GET gmail.com/kyle.marek.spartz

If I wanted mark message 123 as spam:

    POST gmail.com/kyle.marek.spartz/123/labels/spam

To get a message's labels:

    GET gmail.com/kyle.marek.spartz/123/labels

To get all spam messages:

    GET gmail.com/kyle.marek.spartz/labels/spam

URL query strings on GETs could be used to filter results by the email metadata:

    GET gmail.com/kyle.marek.spartz?from=gmail.com%2Fmichaeljburling

To send an email, we could POST to someone else's inbox, with the message
content in the request body:

    POST gmail.com/michaeljburling

For security, we can incorporate public keys into the system. Before I can POST
to `gmail.com/michaeljburling`, I would have to get Michael's public key, and
then use it and my private key to sign my message:

    GET gmail.com/michaeljburling/public_key
    POST gmail.com/michaeljburling

Any messages with an invalid signature would go directly to spam, so [email
spoofing](http://en.wikipedia.org/wiki/Email_spoofing) would not be possible.

See also: [Internet Mail 2000](http://en.wikipedia.org/wiki/Internet_Mail_2000).
