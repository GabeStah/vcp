# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
  $('.best_in_place').best_in_place()
  $('#zone-table').dataTable
    ajax: $('#zone-table').data('source')
    lengthMenu: [ [25, 50, 9223372036854775807], [25, 50, "All"] ]
    order: [[0, 'asc']]
    pagingType: 'full_numbers'
    processing: true
    serverSide: true