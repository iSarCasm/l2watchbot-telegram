class User
  attr_reader :user_id, :filter_from, :filter_to, :filter_rates_from, :filter_rates_to, :lang, :last_notified, :notify_period

  def initialize(db, id)
    @db       = db
    values    = @db.exec("SELECT * from users WHERE user_id = $1", [id.to_s]).values[0]

    @user_id            = values[0].to_s
    @filter_from        = values[1].to_s
    @filter_to          = values[2].to_s
    @filter_chronicle   = values[3].to_s
    @filter_rates_from  = values[4].to_s
    @filter_rates_to    = values[5].to_s
    @lang               = values[6]
    @last_notified      = values[7].to_s
    @notify_period      = values[8].to_i
    puts values
  end

  def filter_from=(val)
    @db.exec "UPDATE users SET filter_from = $1 WHERE user_id = $2;", [val.to_s, @user_id.to_s]
    @filter_from = val
  end

  def filter_to=(val)
    @db.exec "UPDATE users SET filter_to = $1 WHERE user_id = $2;", [val.to_s, @user_id.to_s]
    @filter_to = val
  end

  def filter_chronicle
    @filter_chronicle.empty? ? [] : JSON.parse(@filter_chronicle)
  end

  def filter_chronicle=(val)
    val = val.uniq.to_json
    @db.exec "UPDATE users SET filter_chronicle = $1 WHERE user_id = $2;", [val.to_s, @user_id.to_s]
    @filter_chronicle = val
  end

  def filter_rates_from=(val)
    @db.exec "UPDATE users SET filter_rates_from = $1 WHERE user_id = $2;", [val.to_s, @user_id.to_s]
    @filter_rates_from = val
  end

  def filter_rates_to=(val)
    @db.exec "UPDATE users SET filter_rates_to = $1 WHERE user_id = $2;", [val.to_s, @user_id.to_s]
    @filter_rates_to = val
  end

  def lang=(val)
    @db.exec "UPDATE users SET lang = $1 WHERE user_id = $2;", [val.to_s, @user_id.to_s]
    @lang = val
  end

  def last_notified=(val)
    @db.exec "UPDATE users SET last_notified = $1 WHERE user_id = $2;", [val.to_s, @user_id.to_s]
    @last_notified = val
  end

  def notify_period=(val)
    @db.exec "UPDATE users SET notify_period = $1 WHERE user_id = $2;", [val.to_i, @user_id.to_s]
    @notify_period = val.to_i
  end
end
