#!/bin/bash

heroku container:push web --app $1

heroku container:release web --app $1
