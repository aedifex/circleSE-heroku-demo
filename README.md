# Setting Up A Demo

The "Demo" is designed to provide a simple proof of concept for CircleCI, demonstrating CI/CD in practice as well as several product features (e.g. Workflows, Contexts, etc).

NOTE: reset.sh assumes BSD (mac) `sed`

## Prereqs

1. Account on Heroku, an application running on heroku, and a Heroku API key
1. Github account and Github API key
1. An account on CircleCI associated with your Github account and a CircleCI API key

## Getting started

1. Makefiles are your friend. Run `make init` to create your secrets file and fill in the appropriate values, i.e. API keys, etc.
1. If you DO NOT have a heroku application setup, you can create one by running `make heroku`; a heroku application is a logical grouping of resources, e.g. a docker container with unique configuration settings, a CNAME pointing to the application, etc. Meaning...creating a heroku "application" doesn't entail the application we're building on CircleCI, it just provisions the environment.
1. ONCE you have a heroku application setup and the correct values input in the secrets file, run `make` (no args) to provision the demo. Run the demo. Close some deals. Motivate.

## How the Demo actually works

The demo consists of building, testing, and deploying a barebones dockerized Python Flask application serving a single index.html file.

The demo begins with a PR updating the red “Try it now” button to green "Sign up now" is in flight.

Oh no, a test validating the button content failed. Before we merge our PR and update the application code, we have to rectify our failing test. This is clearly indicated on the PR itself; when we click “show failing tests” we’re taken to a build page on CircleCI with detailed output from each build step.

This is a great opportunity to showcase our beautiful UI. After finding the failed assertion statement in the build page (TODO ~ configure test formatting in XML), we're shown which test failed and why. Armed with this newfound knowledge, we update the test using Github’s text editor and commit directly into the "update button" branch. This commit triggers another workflow.

The build passes as the failing test has been rectified. We :shipit: and merge the PR, confident in our code’s integrity. Yet another workflow is triggered (merging the PR into master thus introduces another code path to test/validate) as our code is merged into master. A passing build on master branch will trigger a simple `deploy.sh` script to take our build artefact, a Docker container, and pushes it to Heroku. Heroku is very fast and relatively easy to use, so our application should be deployed in a matter of minutes. No downtime. When we go back to our application, we see the button has changed color. Alas. We can also see a rolling deployment. No downtime.
