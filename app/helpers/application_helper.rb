module ApplicationHelper
  def bootstrap_class_for(flash_type)
    case flash_type.to_sym
      when :success
        "alert-success"
      when :error
        "alert-danger"
      when :alert
        "alert-warning"
      when :notice
        "alert-info"
      else
        flash_type.to_s
    end
  end

  # returns the full title on a per-page basis
  def full_title(page_title)
    base_title = 'VCP'
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end

  def format_points(value)
    number_with_precision(value, precision: 2, strip_insignificant_zeros: true) || 0
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
  MINOR = 8
  TINY = 22

  def self.print
    "#{MAJOR}.#{MINOR}.#{TINY}"
  end
end