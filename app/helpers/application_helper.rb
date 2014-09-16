module ApplicationHelper
  # returns the full title on a per-page basis
  def full_title(page_title)
    base_title = 'VCP'
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end

  # Check if records exist
  def records?(collection)
    return false if collection.nil?
    return true if collection.any?
  end

  # Display base no records found partial if empty collection
  def render_no_records
    render partial: 'utility/no_records_found'
  end

  # Retrieve datetime from string
  def datetime_from_string

  end
end

module APP_VERSION
  MAJOR = 0
  MINOR = 6
  TINY = 121

  def self.print
    "#{MAJOR}.#{MINOR}.#{TINY}"
  end
end