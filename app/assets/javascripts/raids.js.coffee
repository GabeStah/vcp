# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
  $('#raid_started_at').datetimepicker()
  $('#raid_ended_at').datetimepicker()

  $("[id^='add_participation']").on('click', ->
    current_row = $(this).parent().parent()
    new_row = current_row.clone()
    # Count number of rows with matching slug
    total_count = $("tr[data-slug='#{current_row.data('slug')}']").size()
    # replace numbers in all children
    new_row.find('*').each ->
      # id
      id = $(this).attr('id')
      if id?
        $(this).attr('id', id.replace(/(\d+)/g, total_count+1))
      # name
      name = $(this).attr('name')
      if name?
        $(this).attr('name', name.replace(/(\d+)/g, total_count+1))
    # increment row id last
    new_row.attr('id', current_row.attr('id').replace(/(\d+)/g, total_count+1))
    new_row.insertAfter($("tr[data-slug='#{current_row.data('slug')}']").last())
  )

  $(this).on('click', "[id^='delete_participation']", ->
    $(this).parent().parent().remove()
  )

  $('#new-raid-standings').dataTable
    pagingType: 'full_numbers'

  $('#raids-table').dataTable
    ajax: $('#raids-table').data('source')
    lengthMenu: [ [10, 25, 50, 9223372036854775807], [10, 25, 50, "All"] ]
    pagingType: 'full_numbers'
    processing: true
    serverSide: true