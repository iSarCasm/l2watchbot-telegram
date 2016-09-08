require 'mechanize'
require 'sqlite3'
requrie 'singleton'

require 'awesome_print'
require 'pry'


class Crawler
  include Singleton
  SOURCE_WEBSITE = "http://l2tops.ru/"

  def initialize
    @server_db = SQLite3::Database.new "servers.db"
    @result_db = SQLite3::Database.new "results.db"
    @agent = Mechanize.new
  end

  def self.run
    connect
    extract_nodes_from_page.each do |sever_node|
      begin
        server_db.execute(
          "insert into servers (title, chronicles, rates, date) values ( ?, ?, ?, ? )",
          extract_data_from_node sever_node
        )
      rescue Exception => e
        ap "Got error #{e} for page:\n #{sever_node}"
      end
    end
    save_results
  end

  private

  def self.connect
    @page = @agent.get(SOURCE_WEBSITE)
  end

  def self.extract_nodes_from_page
    @page.search('.server')
  end

  def self.extract_data_from_node(node)
    title       = node.at('.name').text
    chronicles  = node.at('.chronicle').text
    rates       = node.at('.rates').text
    date        = node.at('.date').text
    [title, chronicles, rates, date]
  end

  def self.save_results
    server_count = server_db.execute("select COUNT(*) from servers")
    begin
      result_db.execute(
        "insert into results (date, total_servers) values ( ?, ? )",
        [Time.now, servers.length]
       )
    rescue Exception => e
      ap "Got error when saving results: #{e}"
    end
  end
end
