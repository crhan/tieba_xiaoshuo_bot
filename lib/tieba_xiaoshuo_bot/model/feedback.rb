# coding: utf-8
module TiebaXiaoshuoBot
  class Feedback < Sequel::Model
    many_to_one :user
    include BaseModel

    # primary_key :id
    # index:id
    # foreign_key :reporter_id, :users
    # String msg
    # FlaseClass :checked
    # Time :created_at
    # Time :updated_at

    def reporter= user
      if user.instance_of? User
        self[:reporter_id] = user.id
      else
        errors.add(:reporter, "need to be instance of User")
      end
    end
  end
  Feedback.set_dataset DB[:feedbacks]
end
