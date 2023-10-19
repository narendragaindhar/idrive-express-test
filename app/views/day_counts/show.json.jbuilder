# day_counts/show.json.jbuilder

json.day_count @order.day_count
json.content do
  json.order_row_class order_row_class(@order)
  json.day_count_html render(partial: 'day_count', formats: [:html], locals: {order: @order})
end
