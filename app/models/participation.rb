class Participation < ActiveRecord::Base
  belongs_to :character
  belongs_to :raid

  after_update :reset_raid_events
  after_destroy :reset_raid_events

  # character
  validates :character,
            uniqueness: {
                message: '+ Raid + Timestamp already exists.',
                scope: [:raid, :timestamp],
            },
            presence: true
  # in_raid
  validates :in_raid,
            inclusion: [true, false]
  # online
  validates :online,
            inclusion: [true, false]
  # raid
  validates :raid,
            presence: true
  # timestamp
  validates :timestamp,
            presence: true
  validate :timestamp_is_valid_datetime

  # Get appropriate event(s) tags based on current and previous participation flags
  def event(previous)
    previous_symbol = :nil_nil      if previous.nil?
    previous_symbol = :false_false  if !previous.nil? && !previous.online && !previous.in_raid
    previous_symbol = :false_true   if !previous.nil? && !previous.online && previous.in_raid
    previous_symbol = :true_false   if !previous.nil? && previous.online && !previous.in_raid
    previous_symbol = :true_true    if !previous.nil? && previous.online && previous.in_raid

    current_symbol = :false_false  if !self.online && !self.in_raid
    current_symbol = :false_true   if !self.online && self.in_raid
    current_symbol = :true_false   if self.online && !self.in_raid
    current_symbol = :true_true    if self.online && self.in_raid

    # Lookup and check if array or singlet
    event = PARTICIPATION_POSSIBILITIES[previous_symbol][current_symbol]
    # Return single string or joined if array
    if event.is_a?(Array)
      event.join(" & ")
    else
      event
    end
  end

  def matches_filter?(args = {})
    after = args[:after]
    before = args[:before]
    in_raid = args[:in_raid]
    online = args[:online]

    if after.nil? == false
      if self.timestamp.to_datetime < after.to_datetime
        return false
      end
    end
    if before.nil? == false
      if self.timestamp.to_datetime > before.to_datetime
        return false
      end
    end
    if in_raid.nil? == false
      if !(self.in_raid == in_raid)
        return false
      end
    end
    if online.nil? == false
      if !(self.online == online)
        return false
      end
    end
    true #matches
  end

  # Retrieve the next Participation record from ActiveRecord dataset
  def next(dataset)
    if dataset.nil?
      dataset = self.raid.participations
    else
      return nil unless dataset.class == Participation::ActiveRecord_AssociationRelation
    end
    return nil if dataset.nil?
    # Find all by character_id
    dataset = dataset.reject { |p| p.character_id != self.character_id }
    # If count == 1, return nil
    return nil if dataset.size == 1
    # Sort by timestamp
    dataset = dataset.sort_by { |a| a[:timestamp] }
    # Loop with index
    dataset.each_with_index do |p, i|
      if p.id == self.id
        # nil if no next
        return nil if i == dataset.size
        # Return next in array
        return dataset[i+1]
      end
    end
  end

  # Retrieve the previous Participation record from ActiveRecord dataset
  def previous(dataset)
    if dataset.nil?
      dataset = self.raid.participations
    else
      return nil unless dataset.class == Participation::ActiveRecord_AssociationRelation
    end
    return nil if dataset.nil?
    # Find all by character_id
    dataset = dataset.reject { |p| p.character_id != self.character_id }
    # If count == 1, return nil
    return nil if dataset.size == 1
    # Sort by timestamp
    dataset = dataset.sort_by { |a| a[:timestamp] }
    # Loop with index
    dataset.each_with_index do |p, i|
      if p.id == self.id
        # nil if no previous
        return nil if i == 0
        # Return previous in array
        return dataset[i-1]
      end
    end
  end

  def timestamp=(t)
    unless t.blank? || t.class == DateTime || t.class == ActiveSupport::TimeWithZone
      if t.include? 'UTC'
        t = DateTime.strptime(t, DATETIME_FORMAT_UTC)
      else
        t = DateTime.strptime(t, DATETIME_FORMAT)
      end
    end
    super(t)
  end

  private

  def reset_raid_events
    raid.reset_standing_events
  end

  def timestamp_is_valid_datetime
    errors.add(:timestamp, 'must be a valid datetime') if ((DateTime.parse(timestamp.to_s) rescue ArgumentError) == ArgumentError)
  end
end