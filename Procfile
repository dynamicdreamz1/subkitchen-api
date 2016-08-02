web: bundle exec puma -t 5:6 -p ${PORT:-3000} -e ${RACK_ENV:-development}
worker: bundle exec sidekiq -q default -q mailers
