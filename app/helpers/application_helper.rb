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
    return true if collection.any?
    return false
  end

  # Display base no records found partial if empty collection
  def render_no_records
    render partial: 'utility/no_records_found'
  end
end