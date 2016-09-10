class User
  attr_reader :user_id, :filter_from, :filter_to, :filter_chronicle, :filter_rates_from, :filter_rates_to

  def initialize(db, id)
    values    = db.exec("SELECT * from users WHERE user_id = $1", [id.to_s]).values

    @user_id            = values[0]
    @filter_from        = values[1]
    @filter_to          = values[2]
    @filter_chronicle   = values[3]
    @filter_rates_from  = values[4]
    @filter_rates_to    = values[5]
  end
end
