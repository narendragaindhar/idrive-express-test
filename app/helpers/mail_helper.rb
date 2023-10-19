module MailHelper
  # default font style
  def font_style
    "#{font_color} #{font_size} #{font_family} #{line_height}"
  end

  def font_size
    'font-size: 14px;'
  end

  def font_family
    'font-family: Open Sans, Helvetica Neue, Helvetica, Arial, sans-serif;'
  end

  def font_color
    'color: #555555;'
  end

  def line_height
    'line-height: 1.5;'
  end

  def link_color
    'color: #0099dd;'
  end

  def margin_bottom
    'margin: 0 0 10px;'
  end

  def text_plain
    'white-space: pre-wrap; word-wrap: break-word;'
  end
end
