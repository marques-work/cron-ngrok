# cron-ngrok

Uses `ngrok` to establish an SSH tunnel, with configurable abort timeouts and session timeouts. Notifies Slack URL of connection establishment.

Runnable from a RaspberryPI. Cuz that's what I'm doing.

## Dependencies

* `curl`
* `timeout` (or `gtimeout` on MacOS X -- installable via `brew install coreutils`)
* `ngrok` (of course)
* a Slack webhook for notifications

## Configuration

Mostly straightforward, but kind of (read: very) wonky still. You can configure this script with a `tun.conf` file in the same directory as this script (**um, not secure at all - it gets sourced**), or you can configure via environment variables.

Generally, all environment variables precede values in `tun.conf` -- except for `NOTIFY_URL` (i.e. the Slack URL). Yeah, that's weird but this whole script was a hack anyway so I'm not fixing this. Deal with it. But anyhow, if you're configuring by environment variables anyway, you probably don't need to use a `tun.conf`.

## Why?

I'm about a hour or so drive away from a small office network that I'm managing for a family member. Sometimes the ISP "technicians" come by and jack up the router settings (e.g. factory reset) when connectivity sucks (unfortunately that office is stuck on AT&T for the time being), and I lose my port forwards. I don't want to drive all the way to the office to open up ports again.

## Oh the horror!

Yes, this seems like a very not great idea from a security standpoint. But this is MIT licensed, so you can't sue me for this shit. You've been warned.

I'm saving on gas and time that could be better spent at a pub.

KTHXBAI.
