class CheckList < Sequel::Model
  # create_table? :check_lists do
  #   primary_key :id
  #   foreign_key :fiction_id, :fictions
  #   Time :created_at
  # end
  many_to_one :fiction
  plugin :validation_helpers

  def before_save
    self.created_at ||= Time.now
    super
  end
end
