# cron-ngrok

Uses `ngrok` to establish an SSH tunnel, with configurable abort timeouts and session timeouts. Notifies Slack URL of connection establishment.

Runnable from a RaspberryPI. Cuz that's what I'm doing.

## Dependencies

* `curl`
* `timeout` (or `gtimeout` on MacOS X -- installable via `brew install coreutils`)
* `ngrok` (of course)
* a Slack webhook for notifications

## Configuration

It's probably a good idea to first get an auth token for `ngrok` (just go to the website and sign up). Then follow the one-liner to write your auth token to your `ngrok.yml` file.

Configuration is mostly straightforward, but kind of (read: very) wonky still. You can configure this script with a `tun.conf` file in the same directory as this script (**um, not secure at all - it gets sourced**), or you can configure via environment variables.

Generally, all environment variables precede values in `tun.conf` -- except for `NOTIFY_URL` (i.e. the Slack URL). Yeah, that's weird but this whole script was a hack anyway so I'm not fixing this. Deal with it. But anyhow, if you're configuring by environment variables anyway, you probably don't need to use a `tun.conf`.

### Environment Variables in `tun.conf`
```bash
export KEEPALIVE="900" # number of seconds to keep an established tunnel open (15 min default)
export ABORT_AFTER="60" # connection timeout in seconds before disconnecting on failure
export MONITOR_LOG="/tmp/ngrok.log" # the log to monitor for ngrok events; used to detect a successful tunnel
export NOTIFY_URL="..." # the Slack endpoint to receive notifications
export TZ=":America/Los_Angeles" # sets the time zone for timestamps - otherwise this will probably output UTC
```

## `crontab` notes

First off, I configured this script in my user `crontab`, not as `root`. `root` is simply not necessary with `ngrok`.

If you have `ngrok` installed in a directory that's added to your `PATH` from within `.bashrc` or `.bash_profile`, remember to invoke the script with `bash -l`, like so: `/bin/bash -l /path/to/mktun.sh >> /path/to/the.log`. In fact, just do that anyway so `ngrok` will automatically pick up your `ngrok.yml` file in your homedir.

Be wary of the append redirect `>>` unless you have `logrotate` configured. Might be just good enough to do `>`, which is what I did -- I only care about the last run.

## Why?

I'm about a hour or so drive away from a small office network that I'm managing for a family member. Sometimes the ISP "technicians" come by and jack up the router settings (e.g. factory reset) when connectivity sucks (unfortunately that office is stuck on AT&T for the time being), and I lose my port forwards. I don't want to drive all the way to the office to open up ports again. Nobody in the office is technical, or reliable enough to be "remote hands."

## Oh the horror!

Yes, this seems like a very not great idea from a security standpoint. But this is MIT licensed, so you can't sue me for this shit. You've been warned.

I'm saving on gas and time that could be better spent at a pub.

KTHXBAI.
