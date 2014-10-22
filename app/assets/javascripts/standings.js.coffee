# INDEX
jQuery ->
  $('#standing-table').dataTable
    ajax: $('#standing-table').data('source')
    lengthMenu: [ [25, 50, 9223372036854775807], [25, 50, "All"] ]
    order: [[4, 'desc']]
    pagingType: 'full_numbers'
    processing: true
    serverSide: true

  # Create Raids datatable
  $('#standing-transfer-table').dataTable
    ajax: $('#standing-transfer-table').data('source')
    lengthMenu: [ [50, 9223372036854775807], [50, "All"] ]
    pagingType: 'full_numbers'
    processing: true
    serverSide: true