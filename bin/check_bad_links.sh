#!/usr/bin/env bash
set -e
stack exec site check # | grep Broken.link
