require 'mechanize'
require 'sqlite3'
require 'awesome_print'
require 'pry'


class Crawler
  SOURCE_WEBSITE = "http://l2tops.ru/"

  def self.run
    server_db = SQLite3::Database.new "servers.db"
    result_db = SQLite3::Database.new "results.db"
    agent = Mechanize.new

    page = agent.get(SOURCE_WEBSITE)
    page_servers = page.search('.server')

    page_servers.each do |page_server|
      begin
        title       = page_server.at('.name').text
        chronicles  = page_server.at('.chronicle').text
        rates       = page_server.at('.rates').text
        date        = page_server.at('.date').text

        server_db.execute(
          "insert into servers (title, chronicles, rates, date) values ( ?, ?, ?, ? )",
          [title, chronicles, rates, date]
        )
      rescue Exception => e
        ap "Got error #{e} for page:"
        ap page_server
      end
    end

    servers = server_db.execute("select * from servers")
    servers.each { |s| p s }
    ap "Servers in total: #{servers.length}"

    begin
      result_db.execute(
        "insert into results (date, total_servers) values ( ?, ? )",
        [Time.now, servers.length]
       )
    rescue Exception => e
      ap "Got error when saving results:"
      ap e
    end
  end
end
