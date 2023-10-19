# Make Ruby 2.4 preserve the timezone of the receiver when calling `to_time`.
# Rails < 5.X had false.
ActiveSupport.to_time_preserves_timezone = true
