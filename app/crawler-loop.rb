require './crawler'
require 'logger'

SECONDS_IN_MIN  = 60
MIN_IN_HOUR     = 60
SECONDS_IN_HOUR = SECONDS_IN_MIN * MIN_IN_HOUR

logger = Logger.new('fatal.log', 'daily')

loop do
  begin
    Crawler.instance.run
  rescue Exception => e
    logger.fatal "\n#{e}\n#{e.backtrace}"
  end
  sleep(SECONDS_IN_HOUR * 3)
end
