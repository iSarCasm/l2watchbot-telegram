require './crawler'

SECONDS_IN_MIN  = 60
MIN_IN_HOUR     = 60
SECONDS_IN_HOUR = SECONDS_IN_MIN * MIN_IN_HOUR

loop do
  Crawler.instance.run
  sleep(SECONDS_IN_HOUR * 3)
end
