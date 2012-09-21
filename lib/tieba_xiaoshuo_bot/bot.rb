# coding: utf-8
module TiebaXiaoshuoBot
  require 'tieba_xiaoshuo_bot/patch/rexml_utf_patch'
  require 'xmpp4r/client'
  require 'xmpp4r/roster'
  require 'tieba_xiaoshuo_bot/patch/gtalk_message_patch'
  class Bot
    SHORT_COMMAND ={
      "c" => 'check',
      "s" => 'sub',
      "us" => 'unsub',
      "sm" => 'switch_mode',
      "m" => 'show_mode',
      "h" => 'help',
      "?" => 'help',
      "ls" => 'list',
      "l" => 'list',
      "fb" => 'feedback',
      "ab" => "about",
      "co" => "count",
    }
    def initialize gtalk
      connect gtalk
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

推送小说有两种模式( 通过 `-sm` 指令切换):
"主动" 模式即抓取到小说立即推送给您( 每 5 分钟检查一次新小说 )
"被动" 模式则需要您发送命令 `-check`(短命令 `-c`) 给我才会推送新收集到的小说给您哦

*****
* -c/-check: 在 __被动__ 模式下查看积累的更新
* -s/-sub <小说名>: 订阅小说(请先检查对应贴吧是否有小说更新服务)
* -us/-unsub <小说名>: 退订已订阅的小说
* -sm/-switch_mode: 在 __主动__ 和 __被动__ 推送模式之间切换
* -m/-show_mode: 看看自己是在主动模式还是被动模式
* -h/-?/-help: 查看帮助
* -l/-ls/-list: 查看已订阅(包括已退订)的小说
* -fb/-feedback: 给我提意见啦
* -ab/-about: 无聊卖萌(女神提供的台词)
* -co/-count: 看看我已经发给你多少章小说啦
*****
HERE
    end

    def help
      # TODO send a HTML help message
    end

    # receive an User object and an array of CheckList objects
    def sendMsg user, content, wait = false
      # find the user account send to
      send_to = if user.instance_of? User
             user.account
           elsif user.instance_of? String
             user
           elsif user.instance_of? Fixnum
             User.find(:id => user).account
           end
      msg = Jabber::Message.new(send_to).set_type(:chat)
      if content.instance_of? Array
        content.each do |e|
          @cl.send(msg.set_body(e.to_s))
          $logger.info %|Send Message to "#{send_to}", with "#{e.to_s}"|
        end
      elsif content.instance_of? String
        @cl.send(msg.set_body(content))
        $logger.info %|Send Message to "#{send_to}", with "#{content}"|
      end
      sleep 0.4 if wait
    end


    def reconnect
      if @cl.is_disconnected?
        connect
        Worker::LogError.perform_async "server reconnected", e.message
        true
      else
        false
      end
    end

    def is_disconnected?
      @cl.is_disconnected?
    end

    def close
      @cl.close
    end


    private

    def connect gtalk=nil
      # loggin to gtalk server
      # Jabber::debug = true
      @gtalk ||= gtalk
      @cl ||= Jabber::Client.new(@gtalk["account"])
      @cl.connect
      @cl.auth(@gtalk["password"])

      # set online
      @cl.send(Jabber::Presence.new)
      $logger.info %|#{@gtalk['account']} Connected !|

      # get the roster
      @roster = Jabber::Roster::Helper.new(@cl)
    end

    def auto_update_roster_item
      # register the exist subscription to User model
      @roster.add_query_callback do |r|
        @roster.items.each do |k,v|
          # create user if not exist
          jid = v.jid.strip.to_s
          User.find_or_create(:account => jid)
          $logger.debug "user #{jid} found in rosterItem"
        end
      end
    end

    def auto_accept_subscription_resquest
      # accept any of the XMPP subscription request
      @roster.add_subscription_request_callback do |item,presence|
        @roster.accept_subscription(presence.from)
        # send back subscription request
        @cl.send(Jabber::Presence.new.set_type(:subscribe).set_to(presence.from))
        # greating to the new friend
        $logger.info "accept roster subscription from #{presence.from.to_s}"
        @cl.send(Jabber::Message.new(presence.from, @about_message).set_type(:chat))
      end
    end

    def add_message_callback
      @cl.add_message_callback do |m|
        if m.type == :chat and !m.body.nil?
          user = User.find_or_create(:account => m.from.strip.to_s)
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
        args = msg[1..-1].split(/[\s ]/)
        comm = args.shift
        $logger.debug %|args is #{args.to_s}|
        $logger.debug %|comm is #{args.to_s}|
        comm = SHORT_COMMAND[comm] if SHORT_COMMAND[comm]
        $logger.debug %|parsing command is "#{comm}"|
        func_name = "func_" + comm
        $logger.debug %|running "#{func_name} #{user} #{args.to_s}"|

        begin
          __send__ func_name, user, *args
        rescue RuntimeError => e
          Worker::LogError.perform_async user.account ,e.message, e.backtrace
          sendMsg user, %|中奖，我也不知道为什么这里错了，不过这个错误已经记录下来啦！|
        rescue NoMethodError => e
          Worker::LogError.perform_async user.account, e.message, e.backtrace
        end
      else
        Worker::LogError.perform_async user.account, msg
        sendMsg user, %|请输入(不包括引号) '-?' 查看帮助|
      end
    end

    def method_missing method, *args
      if method =~ /^func_.*/
        user = args[0]
        content = args[1..-1].join(" ") unless args.empty?
        Worker::LogError.perform_async user.account, %|-#{method} #{content}|
        sendMsg user, %|您输入的 `-#{method[5..-1]} #{ content }` 似乎不是有效的命令, 请参阅帮助(输入`-?`)|
      else
        super
      end
    end

    # args[0] => user
    # args[1] => sub fiction_name
    def func_sub *args
      Worker::Sub.perform_async args[1], args[0].id
    end

    # args[0] => user
    # args[1] => unsub fiction_name
    def func_unsub *args
      Worker::UnSub.perform_async args[1], args[0].id
    end

    # args[0] => user
    def func_check *args
      user = args[0]
      if user.initiative?
        sendMsg user, %|请输入 `-sw` 切换到 "被动" 模式再使用此命令哦~|
      else
        sendMsg user, %|小说章节检查中|
        Worker::Send.perform_async nil, user.id, true
        $logger.debug %|Worker::Send.perform_async nil, #{user.id}|
      end
    end

    # args[0] => user
    def func_show_mode *args
      user = args[0]
      sendMsg user, %|您现在处于 "#{user.mode}" 模式|
    end

    # args[0] => user
    def func_switch_mode *args
      user = args[0]
      sendMsg user, %|已将您切换到 "#{user.switch_mode}" 模式|
    end

    def func_feedback *args
      user = args[0]
      content = args[1..-1]
      $logger.info %|receive feed back from "#{user.account}", content: "#{content}"|
      if Feedback.create(:msg => content, :reporter => user)
        sendMsg user, %|收到您的反馈啦～|
      else
        raise RuntimeError, "简直不能相信这里出错 "
      end
    end

    # args[0] => user
    def func_list *args
      sendMsg args[0], args[0].list_subscriptions
    end

    # args[0] => user
    def func_help *args
      sendMsg args[0], @help_message
    end

    # args[0] => user
    def func_about *args
      sendMsg args[0], @about_message
    end

    # args[0] => user
    def func_count *args
      user = args[0]
      sendMsg user, %/我已经给您传递了 "#{user.total_count}" 篇小说啦~/
    end

  rescue IOError => e
    Worker::LogError.perform_async "IOError from Bot class: #{__LINE__}", e.message
    @cl.reconnect
    sleep 2
    retry
  rescue Jabber::ServerDisconnected => e
    Worker::LogError.perform_async "Jabber::ServerDisconnected from Bot class #{__LINE__}", e.message
    @cl.reconnect
    sleep 2
    retry
  end
end
