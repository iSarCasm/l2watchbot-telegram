require 'json'

class TelegramResponder
    def initialize(bot, database)
      @bot = bot
      @database = database
    end

    def respond_to(message)
      @all      = @database.exec("SELECT * from servers").values
      @user     = User.new(@database, message.from.id)
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
        help(message)
      when '/help'
        help(message)
      when '/soon'
        send_servers soon(@all, 7), message
        add_help_to_end(message)
      when '/recent'
        send_servers recent(@all, 7), message
        add_help_to_end(message)
      when '/info'
        info(message)
        add_help_to_end(message)
      when '/filter'
        kb = [
          [Telegram::Bot::Types::KeyboardButton.new(text: 'C1-C4'),
          Telegram::Bot::Types::KeyboardButton.new(text: 'Interlude')],
          [Telegram::Bot::Types::KeyboardButton.new(text: 'Interlude+'),
          Telegram::Bot::Types::KeyboardButton.new(text: 'High five')],
          [Telegram::Bot::Types::KeyboardButton.new(text: 'Epilogue'),
          Telegram::Bot::Types::KeyboardButton.new(text: 'Classic')],
          Telegram::Bot::Types::KeyboardButton.new(text: 'Freya and newer'),
          Telegram::Bot::Types::KeyboardButton.new(text: I18n.t('enough'))
        ]
        markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb, one_time_keyboard: true)
        @bot.api.send_message(chat_id: message.chat.id, text: I18n.t('select_chronicle'), reply_markup: markup)
      when '/notify'
        @bot.api.send_message(chat_id: message.chat.id, text: "Not implemented yet!")
      else
        @bot.api.send_message(chat_id: message.chat.id, text: message.text)
      end
    end

    def respond_to_callback_query(message)
      case message.data
      when 'C1-C4'
        p 'rofl'
      when 'Interlude'
        p 'rofl'
      when 'Interlude+'
        p 'rofl'
      when 'High five'
        p 'rofl'
      when 'Epilogue'
        p 'rofl'
      when 'Classic'
        p 'rofl'
      when 'Freya and newer'
        p 'rofl'
      end
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

    def help(message)
      @bot.api.send_message(chat_id: message.chat.id, text: "#{I18n.t('command_list')}\n/soon\n/recent\n/info\n/help")
    end

    def info(message)
      @bot.api.send_message(chat_id: message.chat.id, text: "#{I18n.t('total_servers')} #{@all.length}")
    end

    def soon(servers, days)
      servers.select do |server|
        date_diff(Time.now, server[3]) > 0 && date_diff(Time.now, server[3]) <= days
      end.sort do |s1, s2|
        date_diff(Time.now, s2[3]) <=> date_diff(Time.now, s1[3])
      end
    end

    def add_help_to_end(message)
      @bot.api.send_message(chat_id: message.chat.id, text: t('need_help'))
    end

    def recent(servers, days)
      servers.select do |server|
        date_diff(Time.now, server[3]) < 0 && date_diff(Time.now, server[3]) >= -days
      end.sort do |s1, s2|
        date_diff(Time.now, s1[3]) <=> date_diff(Time.now, s2[3])
      end
    end

    def filter(servers, chronicle, rates_from, rates_to)

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
