module DatesHelper
  # nice text version of a DateTime object
  def nice_date_time(date_and_time, include_time: false, show_today: true, show_on_or_at: false)
    time_format = ''
    now = Time.zone.now
    if show_today || (date_and_time.to_date != now.to_date)
      time_format << 'on ' if show_on_or_at
      time_format << '%b %d'
      time_format << ', %Y' if date_and_time.year != now.year
    end
    time_format << ' at' if show_on_or_at
    time_format << ' %l:%M%P' if include_time
    date_and_time.strftime time_format
  end
end
