require 'mechanize'
require 'pg'
require 'singleton'
require 'logger'

require 'awesome_print'
require 'pry'


class Crawler
  include Singleton
  SOURCE_WEBSITE = "http://l2tops.ru/"

  def initialize
    @logger    = Logger.new('./../log/logfile.log', 10, 1_024_000)
    @database  = PG.connect( dbname: "l2watchbot", user: "postgres", password: "postgres" )
    @agent     = Mechanize.new
  end

  def run
    connect
    extract_nodes_from_page.each do |sever_node|
      begin
        @database.exec(
          "insert into servers (title, chronicles, rates, date) values ($1, $2, $3, $4)",
          extract_data_from_node(sever_node)
        )
      rescue Exception => e
        @logger.warn "#{e} for page:\n #{sever_node}"
      end
    end
    save_results
  end

  private

  def connect
    @page = @agent.get(SOURCE_WEBSITE)
  end

  def extract_nodes_from_page
    @page.search('.server')
  end

  def extract_data_from_node(node)
    title       = node.at('.name').text
    chronicles  = node.at('.chronicle').text
    rates       = node.at('.rates').text[1..-1].to_i
    date        = node.at('.date').text
    [title, chronicles, rates, date]
  end

  def save_results
    server_count = @database.exec("select COUNT(*) from servers").values.first.first.to_i
    begin
      @database.exec(
        "insert into results (date, total_servers) values ($1, $2)",
        [Time.now.iso8601, server_count]
      )
      @logger.info "Total servers: #{server_count}"
    rescue Exception => e
      @logger.error "When saving results: #{e}"
    end
  end
end
