SimpleCov.start do
  add_filter "/spec/"
  add_group "Models", "lib/tieba_xiaoshuo_bot/model"
  add_group "Workers", "lib/tieba_xiaoshuo_bot/worker"
  add_group "Patches", "lib/tieba_xiaoshuo_bot/patch"
end
