document.addEventListener 'turbolinks:load', ->
  $html = $('html')
  unless $html.hasClass('ie8') or $html.hasClass('ie7') or $html.hasClass('ie6')
    $('a[data-disable-with], input[data-disable-with], button[data-disable-with]').each ->
      $(@).data 'disable-with', "<i class='fa fa-spinner fa-spin'></i> #{$(@).data('disable-with')}"
      undefined
  undefined
