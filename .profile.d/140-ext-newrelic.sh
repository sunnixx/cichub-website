if [[ -n "$NEW_RELIC_LICENSE_KEY" ]]; then
	if [[ -f "/app/.heroku/php/bin/newrelic-daemon" ]]; then
		export NEW_RELIC_APP_NAME=${NEW_RELIC_APP_NAME:-${HEROKU_APP_NAME:-"PHP Application on Heroku"}}
		export NEW_RELIC_LOG_LEVEL=${NEW_RELIC_LOG_LEVEL:-"warning"}

		# The daemon is a started in foreground mode so it will not daemonize
		# (i.e. disassociate from the controlling TTY and disappear into the
		# background).
		#
		# Perpetually tail and redirect the daemon log file to stderr so that it
		# may be observed via 'heroku logs'.
		touch /tmp/heroku.ext-newrelic.newrelic-daemon.${PORT}.log
		tail -qF -n 0 /tmp/heroku.ext-newrelic.newrelic-daemon.${PORT}.log 1>&2 &

		# daemon start
		/app/.heroku/php/bin/newrelic-daemon --foreground --port "@newrelic-daemon" --logfile "/tmp/heroku.ext-newrelic.newrelic-daemon.${PORT}.log" --loglevel "${NEW_RELIC_LOG_LEVEL}" --pidfile "/tmp/newrelic-daemon.pid" &

		# give it a moment to connect
		sleep 2
	else
		echo >&2 "WARNING: Add-on 'newrelic' detected, but PHP extension not yet installed. Push an update to the application to finish installation of the add-on; an empty change ('git commit --allow-empty') is sufficient."
	fi
fi
