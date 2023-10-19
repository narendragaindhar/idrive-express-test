document.addEventListener 'turbolinks:load', ->
  if $('#js-csv-files-processing').length > 0
    window.setTimeout(->
      window.location.reload()
    , 750);
