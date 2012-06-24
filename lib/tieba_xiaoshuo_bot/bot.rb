# coding: utf-8
module TiebaXiaoshuoBot
  require 'tieba_xiaoshuo_bot/patch/rexml_utf_patch'
  require 'tieba_xiaoshuo_bot/patch/standard_error'
  require 'xmpp4r/client'
  require 'xmpp4r/roster'
  class Bot
    gtalk = YAML.load_file("config/config.yml")["gtalk"]
    @@myJID = Jabber::JID.new(gtalk["account"])
    @@myPassword = gtalk["password"]
    def initialize
      connect
      auto_update_roster_item
      auto_accept_subscription_resquest
      add_message_callback

      @about_message = <<HERE
Hi，我是小说推送酱，我住在主人家的电脑里，最喜欢做拿到最新鲜的“报纸”送给主人的事了啦～主人们有想看的小说可以告诉我，我会做主人最忠实的小女仆，第一时间获取更新信息，送给主人们哟～=w=～

想知道怎么用我？赶快输入`-help`啦！
HERE

      @help_message= <<HERE
欢迎使用XXXX（我到底叫什么啊喂），这里就是可用的命令列表啦～
所有命令请以英文半角的短横开始哦～

*****
订阅小说: -sub <小说名>
退订小说: -unsub <小说名>
已订阅（过）的小说列表: -list
使用体验反馈: -feedback <内容>
显示本帮助: -help
卖萌: -about
*****
HERE
    end

    def help
      # TODO send a HTML help message
    end

    def cl
      @@cl
    end

    # receive an User object and an array of CheckList objects
    def sendMsg user, content
      # find the user account send to
      send_to = if user.instance_of? User
             user.account
           elsif user.instance_of? String
             user
           elsif user.instance_of? Fixnum
             User.find(:id => user).account
           end
      msg = Jabber::Message.new(send_to).set_type("chat")
      if content.instance_of? Array
        content.each do |e|
          @@instance.reconnect
          @@cl.send(msg.set_body(e.to_s))
          $logger.info %|Send Message to "#{send_to}", with "#{e.to_s}"|
        end
      elsif content.instance_of? String
        @@instance.reconnect
        @@cl.send(msg.set_body(content))
        $logger.info %|Send Message to "#{send_to}", with "#{content}"|
      end
    end

    def auth
      @@cl.connect
      @@cl.auth(@@myPassword)
      # set online
      @@cl.send(Jabber::Presence.new)
      $logger.info "Connected ! send messages to #{@@myJID.strip.to_s}."
    end

    def connect
      # loggin to gtalk server
      # Jabber::debug = true
      @@cl = Jabber::Client.new(@@myJID)
      auth
      # get the roster
      @@roster = Jabber::Roster::Helper.new(@@cl)
    end

    def reconnect
      if @@cl.is_disconnected?
        @@instance.auth
        true
      else
        false
      end
    end

    def is_disconnected?
      @@cl.is_disconnected?
    end

    def close
      @@cl.close
    end

    private

    def auto_update_roster_item
      # register the exist subscription to User model
      @@roster.add_query_callback do |r|
        @@roster.items.each do |k,v|
          # create user if not exist
          jid = v.jid.strip.to_s
          user = User.find_or_create(:account => jid)
          $logger.debug "user #{jid} found in rosterItem"
        end
      end
    end

    def auto_accept_subscription_resquest
      # accept any of the XMPP subscription request
      @@roster.add_subscription_request_callback do |item,presence|
        @@roster.accept_subscription(presence.from)
        # send back subscription request
        @@cl.send(Jabber::Presence.new.set_type(:subscribe).set_to(presence.from))
        # greating to the new friend
        User.find_or_create(:account => prensence.from.strip.to_s)
        $logger.info "accept roster subscription from #{presence.from.to_s}"
        @@cl.send(Jabber::Message.new(presence.from, @about_message).set_type("chat"))
      end
    end

    def add_message_callback
      @@cl.add_message_callback do |m|
        if m.type = :chat and !m.body.nil?
          user = User.find_or_create(:account => m.from.strip.to_s)
          # TODO parse body
          $logger.debug %|--start parsing "#{m.body}" from user "#{user.account}"|
          parse_msg m.body, user
          $logger.debug %|--stop parsing "#{m.body}" from user "#{user.account}"|
        end
      end
    end

    def parse_msg msg, user
      if msg[0].eql? '-' # it is a command
        $logger.debug %|found command "#{msg}"|
        # continue parsing
        comm = msg[1..-1]
        $logger.debug %|parsing command is "#{comm}"|
        case comm
        when /^sub[\s ]/ # subscription request
          Worker::Sub.perform_async comm, user.id
        when /^unsub[\s ]/ # unsubscription request
          Worker::UnSub.perform_async comm, user.id
        when /^list.*/
          sendMsg user,user.list_subscriptions
        when /^feedback.*/
          content = comm[8..-1]
          $logger.info %|receive feed back from "#{user.account}", content: "#{content}"|
          if Feedback.create(:msg => content, :reporter => user)
            sendMsg user, %|收到您的反馈啦～|
          else
            raise RuntimeError, "简直不能相信这里出错 "
          end
        when /^help.*/
          sendMsg user, @help_message
        when /^about.*/
          sendMsg user, @about_message
        else # what's this?
          # send default message
          raise ArgumentError, comm
        end
      else # what's this?
        # send default message
        raise TypeError, msg
      end
    rescue ArgumentError => e
      Worker::LogError.perform_async self, e.message
      sendMsg user, %|what do you mean by sending "#{e.message}" to me?|;
    rescue TypeError => e
      Worker::LogError.perform_async self, e.message
      sendMsg user, e.message
    rescue RuntimeError => e
      Worker::LogError.perform_async self,e.message, e.backtrace
      sendMsg user, %|中奖，我也不知道为什么这里错了，不过这个错误已经记录下来啦！|
    end

    public
    @@instance = Bot.new

    def self.instance
      return @@instance
    end

    private_class_method :new
  rescue IOError => e
    @@instance.reconnect
    sleep 2
    retry
  end
end
