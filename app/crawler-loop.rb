require 'logger'
require_relative 'crawler'

SECONDS_IN_MIN  = 60
MIN_IN_HOUR     = 60
SECONDS_IN_HOUR = SECONDS_IN_MIN * MIN_IN_HOUR

logger = Logger.new('./../log/fatal.log', 'daily')

loop do
  begin
    Crawler.instance.run
  rescue Exception => e
    logger.fatal e
    logger.fatal e.backtrace
  end
  sleep(SECONDS_IN_HOUR * 3)
end
