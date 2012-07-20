module TiebaXiaoshuoBot
  module BaseModel
    def before_create
      super
      time = Time.now
      self.created_at = time
      self.updated_at = time
    end

    def before_update
      super
      self.updated_at = Time.now
    end
  end
end
