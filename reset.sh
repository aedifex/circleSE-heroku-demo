#!/bin/bash

# This script is responsible for setting up, resetting, and destroying the environments
# needed to run the "standard" CircleCI demo. The credentials needed for the API calls as well as
# some of the custom decorators (background images, taglines...etc) are $(source)'d from the file secrets.
# Each method should provide a brief commentary on what the function performs and what values to expect, if any.

set -e

# recreates local project and uses 'sed' to replace template values with custom content (e.g. background photos)
recreate_local_project() {
    echo "Recreating local project..."
    rm -rf temp-application
    cp -r original-application temp-application

    # these commands replcate template fields with custom values
    sed -i '' "s_{{DATE}}_`date`_" temp-application/webapp/static/index.html
    sed -i '' "s_{{IMAGE}}_${IMAGE_URL}_" temp-application/webapp/static/index.html
    sed -i '' "s_{{HEADLINE}}_${HEADLINE}_" temp-application/webapp/static/index.html
    sed -i '' "s_{{TAGLINE}}_${TAGLINE}_" temp-application/webapp/static/index.html
}

# initialize a local git repo...the following function (reset_github) pushes the application upstream
recreate_local_repo() {
    echo "Recreating local repo..."
    git init
    git add -A
    git remote add origin git@github.com:${GH_USER}/${GH_REPO}.git
    git commit -am "Initial commit"
}

# pushes local application code upstream
reset_github() {
    echo "Recreating gh repo..."
    curl -sSk -u "$GH_USER:$GH_TOKEN" -X POST -d @- "https://api.github.com/user/repos" > /dev/null <<EOF
{
  "name": "$GH_REPO",
  "private": false
}
EOF
    git push -f -u origin master
}

# add project to circleci
setup_circleci_project() {
    echo "Configuring project to build on CircleCI"
    headers='Content-Type:application/json'
    URL="https://$CIRCLE_HOST/api/v1.1/project/github/${GH_USER}/${GH_REPO}/envvar?circle-token=$CIRCLE_TOKEN"

    curl -X POST https://circleci.com/api/v1.1/project/github/${GH_USER}/${GH_REPO}/follow?circle-token=$CIRCLE_TOKEN
}

# populate project with project specific envars (as opposed to Contexts variables)
setup_circleci_project_envars() {
    echo "Setting up envars"

    headers='Content-Type:application/json'
    URL="https://circleci.com/api/v1.1/project/github/${GH_USER}/${GH_REPO}/envvar?circle-token=$CIRCLE_TOKEN"

    curl -sS -H $headers $URL --data-binary '{"name":"HEROKU_API_KEY","value": "'"$HEROKU_API_KEY"'"}'
    curl -sS -H $headers $URL --data-binary '{"name":"HEROKU_LOGIN","value": "'"$HEROKU_LOGIN"'"}'
    curl -sS -H $headers $URL --data-binary '{"name":"HEROKU_APPLICATION","value": "'"$HEROKU_APPLICATION"'"}'

}

# make a small change, push change upstream on feature branch (update button), and create PR
recreate_pr() {
    echo "Recreating feature branch and PR..."
    git checkout -b update-button
    sed -i '' 's_<a class="cta cta-red" href="#">Try it now</a>_<a class="cta cta-green" href="#">Sign up now</a>_' webapp/static/index.html
    git commit -am "Update button"
    git push -f origin update-button
    curl -sS -u "$GH_USER:$GH_TOKEN" -X POST -d @- "https://api.github.com/repos/$GH_USER/$GH_REPO/pulls" > /dev/null <<EOF
{
  "title": "Update signup button",
  "body": "This is gonna triple our signups!",
  "head": "update-button",
  "base": "master"
}
EOF

}

# setup a new heroku application
setup_heroku() {
    echo "Creating heroku application"
    # return "heroku application ID"
}

# the following functions thoroughly destroy the demo environment

delete_repo() {
	echo "Deleting gh repo..."
	curl -sSv -u "$GH_USER:$GH_TOKEN" -X DELETE "https://api.github.com/repos/$GH_USER/$GH_REPO" > /dev/null
}

source secrets

# might be overkill...though containing most of the demo's scaffolding logic in a single script has its' advantages
case $1 in
    reset)      echo "reset 1"
                recreate_local_project
                (cd temp-application && recreate_local_repo)
                (cd temp-application && reset_github)
                setup_circleci_project
                setup_circleci_project_envars
                (cd temp-application && recreate_pr)
                ;;
    heroku)     echo "call setup_heroku script hereß"
                ;;
    destroy)    
esac

echo "reset.sh successfully executed...good luck!" && exit 0
