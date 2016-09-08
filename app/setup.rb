require 'sqlite3'

server_db = SQLite3::Database.new "servers.db"

server_db.execute <<-SQL
  create table servers (
    title text,
    chronicles text,
    rates int,
    date text,
    unique (title, chronicles, rates, date)
  );
SQL

results_db = SQLite3::Database.new "results.db"

results_db.execute <<-SQL
  create table results (
    date text,
    total_servers int
  )
SQL
