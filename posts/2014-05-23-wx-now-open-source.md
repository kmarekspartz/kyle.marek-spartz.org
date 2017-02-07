---
title: WX now Open Source
tags: python, web-dev, databases, wx, pymntos, open-source
description: Announcing WX, a web app for weather stations
---

I have two Raspberry Pis from one of the first US batches and haven't done anything with them until just recently. I'm working toward a RPi weather station!

Instead of having the weather station be its own web server, since it may go in and out of range of the internet or lose power, I decided to make a web app and deploy it elsewhere. It also will allow the RPi to submit measurements via a Rest API.

Recently, I saw a lightning talk demonstrating the use of [Peewee](http://peewee.readthedocs.org/en/latest/), and I thought it looked pretty neat. I decided to play with Peewee (no pun intended) by implementing a quick version of the Rest API and web app. So far I've gotten the Rest API and an Admin interface together, as [Flask-Peewee](http://flask-peewee.readthedocs.org/en/latest/) does this automatically.

Today, I put WX on [GitHub](https://github.com/zeckalpha/wx).

I'm going to make a branch with [SQLAlchemy](http://sqlalchemy.readthedocs.io/en/latest/) models so that I can directly compare the two. I'll be giving a talk at the upcoming [PyMNtos Web Dev Meetup](http://www.meetup.com/PyMNtos-Twin-Cities-Python-User-Group/events/182901522/) about their comparative strengths and weaknesses.

Eventually, I plan on using [Hammock](https://github.com/kadirpekel/hammock) to implement a client that will run on one of my RPis to collect and submit weather measurements.
