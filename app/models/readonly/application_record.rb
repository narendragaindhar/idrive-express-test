module Readonly
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
    establish_connection "readonly_#{Rails.env}".to_sym
  end
end
