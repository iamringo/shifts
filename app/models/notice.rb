class Notice < ActiveRecord::Base

  belongs_to :author, :class_name => "User"
  belongs_to :remover, :class_name => "User"

  belongs_to :department

  validate :content_or_link, :presence_of_locations_or_viewers, :proper_time

  named_scope :inactive, lambda {{ :conditions => ["#{:end_time.to_sql_column} <= #{Time.now.utc.to_sql}"] }}
  named_scope :active_with_end, lambda {{ :conditions => ["#{:start_time.to_sql_column} <= #{Time.now.utc.to_sql} and #{:end_time.to_sql_column} > #{Time.now.utc.to_sql}"]}}
  named_scope :active_without_end, lambda {{ :conditions => ["#{:start_time.to_sql_column} <= #{Time.now.utc.to_sql} and #{:indefinite.to_sql_column} = #{true.to_sql}"]}}
  named_scope :upcoming, lambda {{ :conditions => ["#{:start_time.to_sql_column} > #{Time.now.utc.to_sql}"]}}
  named_scope :stickies, lambda {{ :conditions => ["#{:sticky.to_sql_column} = #{true.to_sql}"]}}
  named_scope :announcements, lambda {{ :conditions => ["#{:announcement.to_sql_column} = #{true.to_sql}"]}}
  named_scope :links, lambda {{:conditions => ["#{:useful_link.to_sql_column} = #{true.to_sql}"]}}

  def self.active
    (self.announcements.active_with_end + self.announcements.active_without_end).uniq.sort_by{|n| n.start_time} +
    (self.stickies.active_with_end + self.stickies.active_without_end).uniq.sort_by{|n| n.start_time}
  end

  def self.active_links
    (self.links.active_with_end + self.links.active_without_end).uniq
  end

  def display_for
    display_for = []
    display_for.push "for users #{self.users.collect{|n| n.name}.to_sentence}" unless self.users.empty?
    display_for.push "for locations #{self.locations.collect{|l| l.short_name}.to_sentence}" unless self.locations.empty?
    display_for.join "<br/>"
  end

  def is_current?
    self.end_time ? self.start_time < Time.now && self.end_time > Time.now : self.start_time < Time.now
  end

  def is_upcoming?
    return self.start_time > Time.now if self.start_time
    false
  end

  def is_sticky
    self.sticky
  end

  def viewers
    self.user_sources.collect{|us| us.users}.flatten.uniq
  end

  def display_locations
    self.location_sources.collect{|ls| ls.locations}.flatten.uniq
  end

  def remove(user)
    self.errors.add_to_base "This notice has already been removed by #{remover.name}" and return if self.remover && self.end_time
    self.end_time = Time.now
    self.indefinite = false
    self.remover = user
    true if self.save
  end

  private
  #Validations
  def presence_of_locations_or_viewers
    if self.announcement || self.sticky
      errors.add_to_base "Your notice must display somewhere or for someone." if self.location_sources.empty? && self.user_sources.empty?
    else
      errors.add_to_base "Your link must disply somewhere" if self.location_sources.empty?
    end
  end

  def proper_time
    errors.add_to_base "Start/end time combination is invalid." if self.start_time >= self.end_time if self.end_time
  end

  def content_or_link
    if self.announcement || self.sticky
      errors.add_to_base "Content cannot be blank." if self.content.empty?
    else
      if self.content.split("|$|").first.empty? || self.content.split("|$|").last == "http://"
        errors.add_to_base "Your link must contain a label and a URL."
      end
    end
  end

end

