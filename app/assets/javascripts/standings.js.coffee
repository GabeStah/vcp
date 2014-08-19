# INDEX
jQuery ->
  $('#standing-table').dataTable
    ajax: $('#standing-table').data('source')
    columns: [
      null,
      null,
      null,
      null,
      null,
      { orderable: false }, # edit
    ]
    lengthMenu: [ [25, 50, 9223372036854775807], [25, 50, "All"] ]
    pagingType: 'full_numbers'
    processing: true
    serverSide: true