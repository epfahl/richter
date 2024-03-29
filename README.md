## Summary

`Richter` is a small, poorly organized Elixir-based web service that 
  - periodically ingests near-real-time USGS earthquake data and writes to a Postgres database
  - allows users to subscribe to earthquake notifications
  - allows subscribed users to search for earthquakes that meet certain search criteria
  - provides rudimentary admin access to kick of a backfill task for the last 30 days of earthquake data

`Richter` is constructed in the MVP-just-make-the-dang-thing-work style. Attach whatever
disclaimers you think are prudent.

The development of this app was an exercise in the creation of a Elixir-Plug-Cowboy-Ecto
web service (no Phoenix!), implementation of a simple GenServer-based function scheduler, 
and the exploration of some of the vagaries of Ecto database management. Some of these 
things I didn't know well when I started, and other skills had been collecting dust.

## Before getting started

To use this app on your local machine, you'll need to satisfy a few perquisites:
- make sure that Elixir is installed (v1.13 or greater)
- make sure that Postgres and the PostGIS extension are installed

If you're on a Mac, Elixir is most easily installed with [Homebrew](https://brew.sh/) 
via `brew install elixir`. If you already have Elixir installed, you can get the latest 
version with `brew upgrade elixir`. 

Mac users benefit from access to the Mac-native [Postgres app](https://postgresapp.com/). 
The version of Postgres installed with this app comes packaged with PostGIS (something 
I discovered serendipitously). I also recommend the [Postico](https://eggerapps.at/postico/) 
app for Mac users.

The `Richter` application assumes that Postgres has the following configuration parameters:
- username: "postgres"
- password: "postgres"
- hostname: "localhost"
- port: 5432

These are typically the defaults for a new Postgres installation. If needed, these parameters can
be changed in `config/config.exs`.

## Getting set up

To get started, you'll first want to clone the repo:

```
> git clone https://github.com/epfahl/richter
```

With the repo cloned, repeat the following incantation in your terminal

```
> cd richter         # change to the root of the richter directory
> mix ecto.dump      # dump the "richter" database if it exists
> mix ecto.create    # create the "richter" database
> mix ecto.migrate   # run database migrations
```

These steps set up the database as a clean slate.

If you're unfamiliar with Elixir, `mix` is Elixir's Swiss Army knife for compilation, 
building, code generation, and lots of other things. At this point, don't worry about 
the specifics of the above `mix` tasks; just know that they're needed before we can 
un the app.

## Running the app

When the app is started, a few things happen. First, the web server starts and makes
a number of endpoints available to users and admins (see below). Second, a scheduler
for fetching earthquake data (every minute, by default) initiates. Third, another 
scheduler starts that looks for new earthquake events (also every minute, by default) 
to send to subscribed users.

To kick things off, enter the following command at the project root:

```
> mix run --no-halt
```

By default, the web server is available on port 8765. If you'd like to use a custom 
port number, like 9876, do this:

```
> PORT 9876 mix run --no-halt
```

Once the app starts, the database will immediately populate with earthquakes recorded
within the last hour. At this point, there are no subscribers and no notifications.

## User endpoints

With the app running on port 8765, the base URL for the following endpoints is

```
http://localhost:8765
```

The endpoints that normal users will interact with are as follows.

### Subscription

**POST** `/subscribe`

As the name suggests, this is the user subscription endpoint. This endpoint accepts a
JSON payload, an example of which is

```json
{
  "endpoint": "https://receiver.mywebservice.com/earthquakes",
  "filters": [
    {
      "type": "magnitude",
      "minimum": 1.0
    },
    {
      "type": "event_age_hours",
      "maximum": 24.0
    }
  ]
}
```

The user-provided `endpoint` is the webhook URL that will receive earthquake notifications.
The filters listed above tell the app to notify only for _new_ (not previously notified) 
quakes of magnitude >= 1 and no older than 24 hours. If filters aren't provided (an empty list),
the minimum magnitude defaults to 1.0, and the maximum age defaults to 1 hour.

A subscription request responds with a JSON payload of the form

```json
{
  "data": nil | echo of subscription data,
  "errors": error message | [error messages]
}
```

When a user subscribes, they are assigned a UUID. The user should retain this ID for future
requests to the service.


### Custom event query

**POST** `/filtered_events`

This endpoint allows a subscribed user (yes, the app checks!) to get a list of earthquakes
that satisfy provided search criteria. An example JSON post payload is

```json
{
  "user_id": "f3a76777-65db-4df2-b65b-70737515a1c8",
  "coordinates": {"long": -79.096352, "lat": 36.074600},
  "distance_km": 100.0,
  "max_age_hours": 24.0
}
```

This request will respond with a list of all earthquakes within 100 km of 
(36.074600, -79.096352) that are more recent than 24 hours. Obviously, this
is an incredibly simplistic approach to search, but it serves as an extensible 
demonstration.

A successful request responds with a payload of the form

```json
{
  "data": [earthquake details],
  "errors": []
}
```

## Secret endpoints

Shhhhh...

These endpoints aren't so much secret as they are hacks.

### Notification webhook

**POST** `/notify`

This endpoint acts as a webhook receiver when testing that the service 
correctly sends notifications. The endpoint receives earthquake event
details. The response contains an echo of those details:

```json
{
  "data": earthquake details,
  "errors": []
}
```

### Admin backdoor (for backfills)

**POST** `/admin`

This endpoint is a rudimentary admin portal. But beware! This endpoint doesn't
have any security measures that would prevent unscrupulous actors from doing bad stuff.

A properly formed admin payload is, as of now, stupid silly:

```json
{
  "action": action name
}
```

As of this writing, the only allowed `action name` is "backfill". When this action is executed,
the service will fetch the last 30 days of earthquake data and insert this data into the
database. If the system is working as intended, users should not receive an explosion of
notifications when this backfill completes.

The admin request responds with a message that indicates a successful action or some problem
with the request.


## Caveats and concerns

So many caveats and concerns...

First, while the app has been tested in the _test-it-live_ sense, it is completely
lacking in any serious tests. The only tests (the non-serious ones) are a couple 
documentation tests for utility functions. What I'm saying is, don't try to make money
off of this right away. There's lots of HTTP mocking and other bullet-proofing to be done.

I find the code organization in `Richter` to be a little cringy. There's a significant 
opportunity to clean up some of the abstractions and function interfaces. I also wonder
if the code should better reflect the MVC structure, where the handler modules for 
notification, subscription, etc, could be packed into a "controller" directory. Many 
refactorings to explore...

Take a look at the code comments for notes, todo items, "fixme"s, and thoughts on how
I could have made different life choices. And feel free to explore the extensive commit log
for the many rabbit holes, false starts, sticking points, and attention to irrelevant details.

Also, there are probably bugs. I'd be shocked if there aren't.