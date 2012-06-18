class CheckList < Sequel::Model
  many_to_one :fiction

  def before_save
    self.created_at ||= Time.now
    super
  end
end
