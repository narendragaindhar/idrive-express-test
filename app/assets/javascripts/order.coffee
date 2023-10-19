document.addEventListener 'turbolinks:load', ->
  $ORDER_CSV_INPUT = $('#js-order-csv-input')
  $ORDER_CSV_MODAL = $('#js-order-csv-modal')
  return unless $ORDER_CSV_MODAL.length > 0

  # auto-select csv text when modal is shown
  $ORDER_CSV_MODAL.on 'shown.bs.modal', ->
    $ORDER_CSV_INPUT.select()
    return

  # auto-select csv text on click
  $ORDER_CSV_INPUT.on 'click', ->
    this.select()
    return

  return
