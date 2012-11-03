# vim: encoding=utf-8
module Kernel
  def deprecate old_method, new_method
    define_method(old_method) do | *args, &block|
      warn "#{Time.now} Warning: #{old_method}() is deprecated. Use #{new_method}() insted."
      send new_method, *args, &block
    end
  end
end
