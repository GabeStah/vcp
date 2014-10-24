jQuery ->
  $('[data-toggle="tooltip"]').tooltip()
  $('.dataTable').on 'draw.dt', ->
    $('[data-toggle="tooltip"]').tooltip()