require 'pg'

database = PG.connect( dbname: "l2watchbot", user: "postgres", password: "postgres" )

database.exec <<-SQL
  create table servers (
    title text,
    chronicles text,
    rates int,
    date text,
    created_at text,
    CONSTRAINT uniq UNIQUE(title, chronicles, rates, date)
  );
SQL

database.exec <<-SQL
  create table results (
    date text,
    total_servers int
  )
SQL
