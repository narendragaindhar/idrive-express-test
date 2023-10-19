document.addEventListener 'turbolinks:load', ->
  $('input[data-autocomplete]').on 'mouseup', ->
    this.select()
  return
