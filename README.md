# Senior Civil Service Appraisals

## Environment

For email to work, certain environment variables must be set:

* SMTP_PASSWORD
* SMTP_USERNAME
* SMTP_PORT
* SMTP_ADDRESS
* SMTP_DOMAIN
* EMAIL_NOREPLY_ADDRESS – Used when sending email
* HOST – Used to generate web URLs when sending email
* FEEDBACK_URL – Used for the feedback link in the alpha bar
* SURVEY_URL – A link to a survey to be completed after using the service

For local development, you can use a `.env` file; see `.env.sample` for an
example.

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

## Administration

All administrator functionality is found under `/admin`.
You will be asked to authenticate via a username and password (see _Initial
setup_ above) if necessary.

## Setting up users

You can import users en masse via a CSV file or create/edit/delete them via
the web interface.

The CSV file should have no header row and three columns: _name_,
_email address_, and _manager's email address_ (if appropriate).
The manager email address is used to determine hierarchy.

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
