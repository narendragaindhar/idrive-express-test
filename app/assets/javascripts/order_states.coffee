document.addEventListener 'turbolinks:load', ->
  $order_state_state_select = $('#order_state_state_id')
  if $order_state_state_select.length
    states_data = $order_state_state_select.data 'states'
    $did_notify_checkbox = $('#order_state_did_notify')
    $is_public_checkbox = $('#order_state_is_public')
    $order_state_comments = $('#order_state_comments')
    $order_state_state_select.change ->
      state_id = $(@).val()
      state_data = states_data[state_id]
      $did_notify_checkbox.prop 'checked', state_data.notify
      $is_public_checkbox.prop 'checked', state_data.public
      # .keyup() event necessary to trigger autogrow functionality
      $order_state_comments.val(state_data.description).keyup()
      return
