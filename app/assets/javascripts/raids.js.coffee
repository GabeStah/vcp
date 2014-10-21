# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
#  $('#raid_started_at').datetimepicker()
#  $('#raid_ended_at').datetimepicker()
  # Update timestamp entries based on Start Date
  format_date = (val) ->
    $.formatDateTime('mm/dd/yy gg:ii a', new Date(new Date(val).getTime() + (new Date().getTimezoneOffset() * 60000)))

  $('input[id^=timestamp_]').val(format_date($('#raid_started_at').val()))
  $('#raid_started_at').on('change', (e) ->
    $('input[id^=timestamp_]').val(format_date($('#raid_started_at').val()))
  )

  # Add new row to participation table
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

  # Remove current participation row
  $(this).on('click', "[id^='delete_participation']", ->
    $(this).parent().parent().remove()
  )

  # Generate Raid Standings datatable
  $('#new-raid-standings').dataTable
    columnDefs: [
      {
        sorting: false
        targets: 0
      },
      {
        sorting: false
        targets: 4
        title: "<input type='checkbox' id='select_all_online' /> Online"
      },
      {
        sorting: false
        targets: 5
        title: "<input type='checkbox' id='select_all_in_raid' /> In Raid"
      }
      {
        sorting: false
        targets: 6
      },
    ]
    lengthMenu: [ [25, 50, 9223372036854775807], [25, 50, "All"] ]
    order: [[3, "desc" ]]
    pagingType: 'full_numbers'

  # select_all checkbox in top column for Online
  $("#select_all_online").click ->
    #$('input[id^=online_').trigger('change')
    $('input[id^=online_').prop("checked", this.checked)

  # select_all checkbox in top column for In Raid
  $("#select_all_in_raid").click ->
    $('input[id^=in_raid_').prop("checked", this.checked)

#  # Add new row to participation table
#  $("[id^=online_]").on('change', ->
#    $(this).parent().parent().find("input[id^=unexcused]").prop('disabled', this.checked ? true : false)
#  )

  # Create Raids datatable
  $('#raids-table').dataTable
    ajax: $('#raids-table').data('source')
    lengthMenu: [ [10, 25, 50, 9223372036854775807], [10, 25, 50, "All"] ]
    pagingType: 'full_numbers'
    processing: true
    serverSide: true

  $('#raid-participation-table').dataTable
    ajax: $('#raid-participation-table').data('source')
    columnDefs: [
      {
        sorting: false
        targets: [5]
      },
    ]
    lengthMenu: [ [25, 50, 9223372036854775807], [25, 50, "All"] ]
    order: [[0, 'asc']]
    pagingType: 'full_numbers'
    processing: true
    serverSide: true