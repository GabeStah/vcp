# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# INDEX
jQuery ->
  $('#characters-claimed-table').dataTable
    ajax: $('#characters-claimed-table').data('source')
    columns: [
      null,
      null,
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

  $('#characters-unclaimed-table').dataTable
    ajax: $('#characters-unclaimed-table').data('source')
    lengthMenu: [ [25, 50, 9223372036854775807], [25, 50, "All"] ]
    pagingType: 'full_numbers'
    processing: true
    serverSide: true

  api_copy = $("#api_key_copy_button")
  _defaults = {
    title: 'Copy to clipboard',
    copied_hint: 'Copied!'
  }
  clip = new ZeroClipboard(api_copy)

  clip.on('ready', (client) ->
    api_copy.tipsy()
    api_copy.attr('title', _defaults.title)
  )

  clip.on('aftercopy', (client, args) ->
    copied_hint = $(this).data('copied-hint')
    if (!copied_hint)
      copied_hint = _defaults.copied_hint
    api_copy
      .prop('title', copied_hint)
      .tipsy('show')
      .prop('title', _defaults.title)
  )

  # Select api_key text when focused
  api_text = $('#api_key')
  api_text.click ->
    $(this).select()