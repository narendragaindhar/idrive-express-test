document.addEventListener 'turbolinks:load', ->
  # refresh any orders whose day count is stale
  $('.js-order-day-count-is-stale').each(() ->
    order = $(this);
    $.getJSON('/orders/' + order.data('order-id') + '/day_count').then((data) ->
      order
        .addClass(data.content.order_row_class)
        .find('.js-order-day-count').replaceWith(data.content.day_count_html)
    )
  )
