jQuery ->
  $('#users-table').dataTable
    ajax: $('#users-table').data('source')
    columnDefs: [
      {
        sorting: false
        targets: ['nosort']
      },
    ]
    lengthMenu: [ [25, 50, 9223372036854775807], [25, 50, "All"] ]
    order: [[0]]
    pagingType: 'full_numbers'
    processing: true
    serverSide: true