class TelegramResponder
    def initialize(bot)
      @bot = bot
    end

    def respond_to(message)
      @all = database.exec("SELECT * from servers").values
      case message
      when Telegram::Bot::Types::CallbackQuery
        respond_to_callback_query(message.data)
      when Telegram::Bot::Types::Message
        respond_to_text(message.text)
      end
    end

    private

    def respond_to_text(text)
      case text
      when '/start'
        help
      when '/soon'
        send_servers soon(@all, 14)
      when '/recent'
        send_servers recent(@all, 14)
      when '/filter'
        bot.api.send_message(chat_id: message.chat.id, text: "Not implemented yet!")
      when '/notify'
        bot.api.send_message(chat_id: message.chat.id, text: "Not implemented yet!")
      end
    end

    def respond_to_callback_query(data)
      case data
      when 'lol'
        p 'rofl'
      end
    end

    def send_servers(servers)
      servers.each do |s|
        text = "#{s[0]}\n#{s[1]} #{s[2]}\n#{s[3]}"
        bot.api.send_message(chat_id: message.chat.id, text: text)
      end
    end

    def help
      bot.api.send_message(chat_id: message.chat.id, text: "Hello, #{message.from.first_name}. Command list:\n/soon\n/recent")
    end

    def soon(servers, days)
      server.reject do |server|
        date_diff(Time.now, server[3]) > 0 && date_diff(Time.now, server[3]) <= days
      end
    end

    def recent(servers, days)
      server.reject do |server|
        date_diff(Time.now, server[3]) < 0 && date_diff(Time.now, server[3]) >= days
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
          d = parsed[0] + parsed[1]*30 + parsed[2]*365
        end
        days += (i.even? ? -d : d)
      end
    end
end
