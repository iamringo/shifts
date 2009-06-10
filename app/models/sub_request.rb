class SubRequest < ActiveRecord::Base
  belongs_to :shift

  validates_presence_of :reason
  validates_presence_of :shift
  validate :start_and_end_are_within_shift
  validate :start_less_than_end
  validate :not_in_the_past
  validate :user_does_not_have_concurrent_sub_request
  #
  # Class methods
  #

  def self.take(sub_request, user)
    new_shift = sub_request.shift.clone
    new_shift.location = sub_request.shift.location
    Shift.delete_part_of_shift(sub_request.shift, sub_request.start, sub_request.end)
    new_shift.user = user
    new_shift.start = sub_request.start
    new_shift.end = sub_request.end
    new_shift.save!
    sub_request.destroy
  end

  #
  # Object methods
  #




  private
  def start_and_end_are_within_shift
    unless self.start.between?(self.shift.start, self.shift.end) && self.end.between?(self.shift.start, self.shift.end)
      errors.add("Sub Request must be within shift.", "")
    end
  end



  def start_less_than_end
    errors.add(:start, "must be earlier than end time") if (self.end <= start)
  end

  def not_in_the_past
    errors.add_to_base("Can't create a sub request for a time that has already passed!") if self.start < Time.now
  end

  def user_does_not_have_concurrent_sub_request
    c = SubRequest.count(:all, :conditions => ['shift_id = ? AND start < ? AND end > ?', self.shift_id, self.end, self.start])
    unless c.zero?
      errors.add_to_base("#{self.shift.user.name} has an overlapping sub request in that period") unless (self.id and c==1)
    end
  end

end
