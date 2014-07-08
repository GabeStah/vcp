# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
  $('#setting_raid_start_time').datetimepicker({
    pickDate: false
  })
  $('#setting_raid_end_time').datetimepicker({
    pickDate: false
  })