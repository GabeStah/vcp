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
        targets: 3
        title: "Online <span id='select-all-online' class='glyphicon glyphicon-ok' data-tip='Mark All Online'></span>"
      },
      {
        targets: 4
        title: "In Raid <span id='select-all-in-raid' class='glyphicon glyphicon-ok' data-tip='Mark All In Raid'></span>"
      }
      {
        sorting: false
        targets: ['nosort']
      },
    ]
    lengthMenu: [ [25, 50, 9223372036854775807], [25, 50, "All"] ]
    order: [[2, "desc" ]]
    pagingType: 'full_numbers'

  # select_all checkbox in top column for Online
  $("#select-all-online").click ->
    $('input[id^=online_').prop("checked", !this.checked)

  # select_all checkbox in top column for In Raid
  $("#select-all-in-raid").click ->
    $('input[id^=in_raid_').prop("checked", !this.checked)

  # Tooltips
  $("#select-all-online").each ->
    $(this).tipsy({html: true, title: 'data-tip'})
  $("#select-all-in-raid").each ->
    $(this).tipsy({html: true, title: 'data-tip'})

  $('#new-raid-standings').on 'draw.dt', ->
    $("#select-all-online").each ->
      $(this).tipsy({html: true, title: 'data-tip'})
    $("#select-all-in-raid").each ->
      $(this).tipsy({html: true, title: 'data-tip'})

#  # Add new row to participation table
#  $("[id^=online_]").on('change', ->
#    $(this).parent().parent().find("input[id^=unexcused]").prop('disabled', this.checked ? true : false)
#  )

  # Create Raids datatable
  $('#raids-table').dataTable
    ajax: $('#raids-table').data('source')
    columnDefs: [
      {
        sorting: false
        targets: ['nosort']
      },
    ]
    lengthMenu: [ [10, 25, 50, 9223372036854775807], [10, 25, 50, "All"] ]
    order: [[2, 'desc']]
    pagingType: 'full_numbers'
    processing: true
    serverSide: true

  $('#raid-participation-table').dataTable
    ajax: $('#raid-participation-table').data('source')
    columnDefs: [
      {
        className: 'center',
        targets: [2,3,4,6]
      },
      {
        sorting: false
        targets: ['nosort']
      },
    ]
    lengthMenu: [ [25, 50, 9223372036854775807], [25, 50, "All"] ]
    order: [[0, 'asc']]
    pagingType: 'full_numbers'
    processing: true
    serverSide: true

  # Points tooltips
  $('#raid-participation-table').on 'draw.dt', ->
    $(".raid-participation-event-tooltip").each ->
      $(this).tipsy({html: true, title: 'data-tip'})