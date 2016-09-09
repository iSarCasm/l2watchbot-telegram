require 'telegram/bot'
require 'pg'

token = '267520876:AAHU_jHQ-kp8vSpklbX4IUMfmmUtzw3T_54'

database  = PG.connect( dbname: "l2watchbot", user: "postgres", password: "postgres" )

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    case message.text
    when '/start'
      bot.api.send_message(chat_id: message.chat.id, text: "Hello, #{message.from.first_name}")
    when '/stop'
      bot.api.send_message(chat_id: message.chat.id, text: "Bye, #{message.from.first_name}")
    when '/all'
      all = database.exec("SELECT * from servers").values
      bot.api.send_message(chat_id: message.chat.id, text: "Here:\n #{all.first(5).to_s}")
    end
  end
end
