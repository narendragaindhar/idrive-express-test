module Sizable
  extend ActiveSupport::Concern
  include ActionView::Helpers::NumberHelper

  UNITS = %w[B KB MB GB TB PB].freeze

  def self.to_bytes(size, units)
    size.to_f * (1024.0**UNITS.index(units.upcase))
  end

  def self.included(base)
    base.extend ClassMethods
    base.send :include, InstanceMethods
  end

  module ClassMethods
    def sizable_attr
      defined?(@sizable_attr) ? @sizable_attr : :size
    end

    def sizable_attr=(attribute)
      @sizable_attr = attribute.to_sym
    end
  end

  module InstanceMethods
    def humanize_size
      number = send(self.class.sizable_attr)
      if number.present?
        number_to_human_size(number)
      else
        ''
      end
    end

    def size_count
      number = send(self.class.sizable_attr)
      if number.present?
        number_to_human_size(number).split(' ').first
      else
        @size_count
      end
    end

    def size_count=(count)
      @size_count = count
      update_sizable_attr
    end

    def size_units
      number = send(self.class.sizable_attr)
      if number.present?
        if number < 1024
          'B' # rails humanize can return multiple values for byte values
        else
          number_to_human_size(number).split(' ').last
        end
      else
        @size_units
      end
    end

    def size_units=(units)
      @size_units = units
      update_sizable_attr
    end

    private

    def update_sizable_attr
      send("#{self.class.sizable_attr}=", Sizable.to_bytes(@size_count, @size_units).to_i) \
        if @size_units.present? && @size_count.present?
    end
  end
end
