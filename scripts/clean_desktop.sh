#!/bin/bash

find ~/Desktop -type f -name "*" -mtime +30 -delete
find ~/Desktop -type d -empty -delete
find ~/Downloads -type f -name "*" -mtime +30 -delete
find ~/Downloads -type d -empty -delete