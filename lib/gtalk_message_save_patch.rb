# -*- encoding : utf-8 -*-
# 默认添加 google:save 属性
module Jabber
  class Message
    def initialize to=nil, body=nil
      super()
      if not to.nil?
        set_to(to)
      end
      if not body.nil?
        add_element(REXML::Element.new("body").add_text(body))
      end

      # add google:nosave by default
      x = X.new.add_namespace("google:nosave")
      x.add_attribute "value","disabled"
      add_element x
    end
  end
end
