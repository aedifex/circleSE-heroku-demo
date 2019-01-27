# Makefile for setting up, running, an reseting CircleCI basic demo.

# programmers traditionally use all as the name of the first target.
all:
	chmod +x ./reset.sh && ./reset.sh reset

# inits demo environment
init:
	@mv secrets.template secrets

heroku:
	@chmod +x ./reset.sh && ./reset.sh heroku
