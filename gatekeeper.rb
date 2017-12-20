# frozen_string_literal: true

require "discordrb"
require "dotenv/load"
require "rufus-scheduler"

bot = Discordrb::Commands::CommandBot.new token: ENV["TOKEN"], client_id: ENV["CLIENT_ID"], prefix: ["??"]
current_status = true


scheduler = Rufus::Scheduler.new
scheduler.every "15m" do
  server = bot.servers[ENV["SERVER_ID"].to_i]
  channels = server.text_channels.select { |c| (c.name == "bot-spam2" || c.name == "bot-spam") }
  role = server.roles.select {|r| r.name == "@everyone"}.first

  allow = Discordrb::Permissions.new
  allow.can_read_messages = true
  deny = Discordrb::Permissions.new
  deny.can_send_messages = true

  channels.each do |c|
    msg = "このチャンネルへの書き込みを制限します。"
    if current_status
      c.define_overwrite(role ,allow, deny)
    else
      msg = "このチャンネルへの書き込み制限を解除します。"
      c.delete_overwrite(role)
    end
    bot.send_message(c.id, msg)
  end
  current_status = !current_status
end

bot.run
