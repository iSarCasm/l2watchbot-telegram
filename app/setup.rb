require 'sqlite3'

database = SQLite3::Database.new "db/l2watchbot.db"

database.execute <<-SQL
  create table servers (
    title text,
    chronicles text,
    rates int,
    date text,
    created_at text,
    unique (title, chronicles, rates, date)
  );
SQL

database.execute <<-SQL
  create table results (
    date text,
    total_servers int
  )
SQL
