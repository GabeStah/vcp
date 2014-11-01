# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# INDEX
jQuery ->
  $('#characters-claimed-table').dataTable
    ajax: $('#characters-claimed-table').data('source')
    columnDefs: [
      {
        className: 'center',
        targets: [1,4,6,7]
      },
      {
        sorting: false
        targets: ['nosort']
      },
    ]
    lengthMenu: [ [25, 50, 9223372036854775807], [25, 50, "All"] ]
    pagingType: 'full_numbers'
    processing: true
    serverSide: true

  $('#characters-table').dataTable
    ajax: $('#characters-table').data('source')
    columnDefs: [
      {
        className: 'center',
        targets: [1,4,6]
      },
      {
        sorting: false
        targets: ['nosort']
      },
    ]
    lengthMenu: [ [25, 50, 9223372036854775807], [25, 50, "All"] ]
    pagingType: 'full_numbers'
    processing: true
    serverSide: true

  # Generate Raid Standings datatable
  $('#character-history-table').dataTable
    ajax: $('#character-history-table').data('source')
    columnDefs: [
      {
        sorting: false
        targets: ['nosort']
      },
    ]
    lengthMenu: [ [25, 50, 9223372036854775807], [25, 50, "All"] ]
    order: [[1, 'desc']]
    pagingType: 'full_numbers'
    processing: true
    serverSide: true

  # Points tooltips
  $('#character-history-table').on 'draw.dt', ->
    $(".character-history-tooltip").each ->
      $(this).tipsy({html: true, title: 'data-tip'})