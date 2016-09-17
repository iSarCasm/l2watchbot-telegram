class TelegramResponder
  def initialize(bot, database)
    @bot = bot
    @database = database
  end

  def filter_keyboard
    types = ['C1-C4', 'Interlude', 'Epilogue', 'High five', 'Classic', I18n.t('other')]
    types.delete('C1-C4')         if @user.filter_chronicle.include?('c1')
    types.delete('Interlude')     if @user.filter_chronicle.include?('interlude')
    types.delete('Epilogue')      if @user.filter_chronicle.include?('epilogue')
    types.delete('High five')     if @user.filter_chronicle.include?('high five')
    types.delete('Classic')       if @user.filter_chronicle.include?('classic')
    types.delete(I18n.t('other')) if @user.filter_chronicle.include?('freya')
    pairs = []
    types.each_with_index do |t, i|
      if i.even? then
        pairs << [t]
      else
        pairs.last << t
      end
    end
    pairs << Telegram::Bot::Types::KeyboardButton.new(text: I18n.t('enough'))
  end

  def respond_to(message)
    @all      = @database.exec("SELECT * from servers").values
    @user     = User.new(@database, message.from.id)
    @user.chat_id = message.chat.id
    I18n.locale = (@user.lang || :en).to_sym
    case message
    when Telegram::Bot::Types::CallbackQuery
      respond_to_callback_query(message)
    when Telegram::Bot::Types::Message
      respond_to_text(message)
    end
  end

  private

  def respond_to_text(message)
    case message.text
    when '/start'
      if @user.lang then
        help(message)
      else
        ask_lang(message)
      end
    when '/lang'
      ask_lang(message)
    when '/help'
      help(message)
    when '/soon'
      send_servers soon(@all, 14), message
      add_help_to_end(message)
    when '/recent'
      send_servers recent(@all, 14), message
      add_help_to_end(message)
    when '/info'
      info(message)
      add_help_to_end(message)
    when '/filter'
      clear_filter
      ask_filter_chronicle(message)
    when '/lowrate'
      send_servers(from_to(apply_rates_filter(@all, 0, 20), -21, 30), message)
      add_help_to_end(message)
    when '/multicraft'
      send_servers(from_to(apply_rates_filter(@all, 20, 200), -21, 30), message)
      add_help_to_end(message)
    when '/pvprate'
      send_servers(from_to(apply_rates_filter(@all, 200, 99999999), -21, 30), message)
      add_help_to_end(message)
    when '/notify'
      clear_filter
      ask_filter_chronicle(message)
    when 'C1-C4'
      @user.filter_chronicle = @user.filter_chronicle + ['c1', 'c2', 'c3', 'c4']
      send_chronicle_filter(message)
      ask_filter_chronicle(message)
    when 'Interlude'
      @user.filter_chronicle = @user.filter_chronicle + ['interlude', 'interlude+']
      send_chronicle_filter(message)
      ask_filter_chronicle(message)
    when 'High five'
      @user.filter_chronicle = @user.filter_chronicle + ['high five']
      send_chronicle_filter(message)
      ask_filter_chronicle(message)
    when 'Epilogue'
      @user.filter_chronicle = @user.filter_chronicle + ['epilogue']
      send_chronicle_filter(message)
      ask_filter_chronicle(message)
    when 'Classic'
      @user.filter_chronicle = @user.filter_chronicle + ['classic']
      send_chronicle_filter(message)
      ask_filter_chronicle(message)
    when I18n.t('.other')
      @user.filter_chronicle = @user.filter_chronicle + ['final', 'lindvior', 'freya', 'ertheria', 'odyssey']
      send_chronicle_filter(message)
      ask_filter_chronicle(message)
    when I18n.t('enough')
      ask_filter_rates(message)
    when 'Low-Rate'
      @user.filter_rates_from = 0
      @user.filter_rates_to = 15
      ask_for_notifies(message)
    when 'Multi-Craft'
      @user.filter_rates_from = 15
      @user.filter_rates_to = 250
      ask_for_notifies(message)
    when 'PVP-Rate'
      @user.filter_rates_from = 250
      @user.filter_rates_to = 99999999
      ask_for_notifies(message)
    when 'RU'
      @user.lang = 'ru'
      I18n.locale = :ru
      add_help_to_end(message)
    when 'ENG'
      @user.lang = 'en'
      I18n.locale = :en
      add_help_to_end(message)
    when '/reset'
      @user.last_notified = Time.now.iso8601
      filter(message)
      @user.notify_period = nil
    when I18n.t('notify_everyday')
      @user.last_notified = Time.now.iso8601
      filter(message)
      @user.notify_period = 1
    when I18n.t('notify_everyweek')
      @user.last_notified = Time.now.iso8601
      filter(message)
      @user.notify_period = 7
    when I18n.t('notify_everymonth')
      @user.last_notified = Time.now.iso8601
      filter(message)
      @user.notify_period = 30
    else
      @bot.api.send_message(chat_id: message.chat.id, text: message.text)
    end
  end

  def respond_to_callback_query(message)
    # case message.data
    # end
  end

  def send_servers(servers, message)
    servers.each do |s|
      day_diff = date_diff(Time.now, s[3])
      day_part =  if (day_diff > 0) then
                    I18n.t('opens_in_x_days', x: day_diff)
                  elsif (day_diff < 0) then
                    I18n.t('opened_x_days_ago', x: -day_diff)
                  else
                    I18n.t('opens_today')
                  end
      text = "#{s[0]}\n#{s[1]} x#{s[2]}\n#{s[3]} #{day_part}"
      @bot.api.send_message(chat_id: message.chat.id, text: text)
    end
  end

  def ask_lang(message)
    kb = [
      [Telegram::Bot::Types::KeyboardButton.new(text: 'RU'),
      Telegram::Bot::Types::KeyboardButton.new(text: 'ENG')]
    ]
    markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb, one_time_keyboard: true)
    @bot.api.send_message(chat_id: message.chat.id, text: "LANGUAGE", reply_markup: markup)
  end

  def ask_filter_chronicle(message)
    markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: filter_keyboard, one_time_keyboard: true)
    @bot.api.send_message(chat_id: message.chat.id, text: I18n.t('select_chronicle'), reply_markup: markup)
  end

  def ask_filter_rates(message)
    kb = [
      Telegram::Bot::Types::KeyboardButton.new(text: 'Low-Rate'),
      Telegram::Bot::Types::KeyboardButton.new(text: 'Multi-Craft'),
      Telegram::Bot::Types::KeyboardButton.new(text: 'PVP-Rate'),
    ]
    markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb, one_time_keyboard: true)
    @bot.api.send_message(chat_id: message.chat.id, text: I18n.t('choose_rates'), reply_markup: markup)
  end

  def ask_for_notifies(message)
    kb = [
      Telegram::Bot::Types::KeyboardButton.new(text: I18n.t('notify_everyday')),
      Telegram::Bot::Types::KeyboardButton.new(text: I18n.t('notify_everyweek')),
      Telegram::Bot::Types::KeyboardButton.new(text: I18n.t('notify_everymonth')),
    ]
    markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb, one_time_keyboard: true)
    @bot.api.send_message(chat_id: message.chat.id, text: I18n.t('should_we_notify'), reply_markup: markup)
  end

  def send_chronicle_filter(message)
    @bot.api.send_message(chat_id: message.chat.id, text: I18n.t('selected_chronicles', x: @user.filter_chronicle.join(", ")))
  end

  def help(message)
    @bot.api.send_message(chat_id: message.chat.id, text: "#{I18n.t('command_list')}\n/soon\n/recent\n/lowrate\n/multicraft\n/pvprate\n/notify\n/help")
  end

  def info(message)
    @bot.api.send_message(chat_id: message.chat.id, text: "#{I18n.t('total_servers')} #{@all.length}")
  end

  def add_help_to_end(message)
    @bot.api.send_message(chat_id: message.chat.id, text: I18n.t('need_help'))
  end

  def soon(servers, days)
    servers.select do |server|
      date_diff(Time.now, server[3]) > 0 && date_diff(Time.now, server[3]) <= days
    end.sort do |s1, s2|
      date_diff(Time.now, s2[3]) <=> date_diff(Time.now, s1[3])
    end
  end

  def recent(servers, days)
    servers.select do |server|
      date_diff(Time.now, server[3]) < 0 && date_diff(Time.now, server[3]) >= -days
    end.sort do |s1, s2|
      date_diff(Time.now, s1[3]) <=> date_diff(Time.now, s2[3])
    end
  end

  def from_to(servers, from, to)
    servers.select do |server|
      date_diff(Time.now, server[3]) >= from && date_diff(Time.now, server[3]) <= to
    end.sort do |s1, s2|
      date_diff(Time.now, s1[3]) <=> date_diff(Time.now, s2[3])
    end
  end

  def apply_chonicle_filter(servers, chronicles)
    servers.select do |server|
      chronicles.include? server[1]
    end
  end

  def apply_rates_filter(servers, from, to)
    servers.select do |server|
      server[2].to_i >= from.to_i && server[2].to_i <= to.to_i
    end
  end

  def clear_filter
    @user.filter_chronicle = []
  end

  def filter(message)
    send_servers(
      from_to(
        apply_chonicle_filter(
          apply_rates_filter(
            @all,
            @user.filter_rates_from,
            @user.filter_rates_to
          ),
          @user.filter_chronicle
        ),
        -14,
        14
      ),
      message
    )
    add_help_to_end(message)
  end

  def date_diff(*dates)
    days = 0
    dates.each_with_index do |date, i|
      if date.is_a? Time then
        d = date.day + date.month*30 + date.year*365
      else
        parsed = date.split('.').map! { |x| x.to_i }
        d = parsed[0] + parsed[1]*30 + (parsed[2]+2000)*365
      end
      days += (i.even? ? -d : d)
    end
    days
  end
end
