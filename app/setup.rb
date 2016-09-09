require 'pg'

database = PG.connect( dbname: "l2watchbot", user: "postgres", password: "postgres", hostaddr: "postgres://xmeveejkmcemfy:XxvCrubxgW5XbKHL8qvLjkPpFM@ec2-54-228-196-12.eu-west-1.compute.amazonaws.com:5432/d2ulj8p3qmn3v1" )

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
