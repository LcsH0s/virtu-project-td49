#!/bin/sh

# create 3000 votes (2000 for option a, 1000 for option b)
ab -n 1000 -c 50 -p posta -T "application/x-www-form-urlencoded" http://192.168.1.213:5002/
ab -n 1000 -c 50 -p postb -T "application/x-www-form-urlencoded" http://192.168.1.213:5002/
ab -n 1000 -c 50 -p posta -T "application/x-www-form-urlencoded" http://192.168.1.213:5002/
