# Senior Civil Service Appraisals

## Environment

Certain environment variables are required for full operation in the production
environment:

* SMTP_PASSWORD
* SMTP_USERNAME
* SMTP_PORT (optional, defaults to 587)
* SMTP_ADDRESS
* SMTP_DOMAIN
* EMAIL_NOREPLY_ADDRESS – Used when sending email
* HOST – Used to generate web URLs when sending email
* FEEDBACK_URL – Used for the feedback link in the beta bar
* SURVEY_URL – A link to a survey to be completed after using the service
* SECURE_COOKIES - (true/false) whether to set secure cookies or not, set this
                   to false in development/test.
* REDIS_PROVIDER - This is the url for Redis and can include auth information


## Initial setup

First, create an admin user via the shell:

```sh
./bin/create_admin
```

The username and password will be echoed to the terminal:

```
Login created:
username: admin
password: l{VO/2=i;6|+
```

In order to run the application and the job queues for email workflow, the easiest option would be to use [foreman](https://github.com/ddollar/foreman).

```sh
foreman start
```

This will use the configuration from the projects Procfile to run the appropriate processes.

## Administration

All administrator functionality is found under `/admin`.
You will be asked to authenticate via a username and password (see _Initial
setup_ above) if necessary.

## Setting up users

You can import users en masse via a CSV file or create/edit/delete them via
the web interface.

The CSV file should have a header row with these columns:

* `name`
* `email`
* `job_title`
* `manager_email`

The manager email address, where supplied, is used to determine hierarchy.

Uploading a file multiple times will not create duplicate users.
Names of existing users will be updated (using the email address as the
identifier), as will management relationships.

A sample file is included as `demo.csv`.

## Opening and closing the review period

The default is *open*.

Use the *Close review period* or *Open review period* buttons to change this.

## Sending introductions

The review period must be open.

Use the *Send introduction email* button to send emails to all users.

This will send introduction emails containing login links to all the users
created in the previous step.

In development, you can see the emails in the logs. Follow the `/go/` link to
be logged in as that user.

## Notifying participants at the end of the process

At the end of the feedback process, you can close the review period as
explained above.
You can then notify all participants that their feedback is ready to be viewed
using the *Send review period closure emails* button.

## Utilities

* Continuous integration by [Travis](https://travis-ci.org/ministryofjustice/scs_appraisals).
* Code quality by [Code Climate](https://codeclimate.com/github/ministryofjustice/scs_appraisals).
