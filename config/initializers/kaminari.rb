Kaminari.configure do |config|
  # fixes conflict beween will_paginate and kaminari gems
  # see https://github.com/sferik/rails_admin/wiki/Troubleshoot
  config.page_method_name = :per_page_kaminari
end
