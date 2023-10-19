module Helpers
  module DateFilter
    EQUALITY = /[<>]=?|=/
    DATE = /\d{4}-\d{2}-\d{2}/
    TIME = /\d{2}:\d{2}:\d{2}/
    DATETIME = /#{DATE}T#{TIME}/

    RANGE_RE = /\A(#{DATE}(T#{TIME})?)\.\.(#{DATE}(T#{TIME})?)\z/
    DATE_TIME_RE = /\A(#{EQUALITY})?(#{DATETIME})\z/
    DATE_RE = /\A(#{EQUALITY})?(#{DATE})\z/
    TODAY_RE = /\Atoday\z/i

    EQUALS = '='.freeze

    def self.filter(relation, column, date_string)
      column = columnize(column)

      case date_string
      when TODAY_RE
        relation.where(between(column),
                       Time.zone.now.beginning_of_day,
                       Time.zone.tomorrow.beginning_of_day)
      when RANGE_RE
        relation.where(between(column),
                       Time.zone.parse(Regexp.last_match(1)),
                       Time.zone.parse(Regexp.last_match(3)))
      when DATE_TIME_RE
        relation.where(condition(column, equalitize(Regexp.last_match(1))),
                       Time.zone.parse(Regexp.last_match(2)))
      when DATE_RE
        sign = equalitize(Regexp.last_match(1))
        time = Time.zone.parse(Regexp.last_match(2))

        # equal is special as we match the whole day
        if sign == EQUALS
          relation.where(between(column), time, time.tomorrow)
        else
          relation.where(condition(column, sign), time)
        end
      else
        relation
      end
    end

    def self.condition(column, sign)
      "#{column} #{sign} ?"
    end
    private_class_method :condition

    def self.between(column)
      "#{column} BETWEEN ? AND ?"
    end
    private_class_method :between

    def self.columnize(column)
      if column.is_a? Symbol
        "`#{column}`"
      else
        column
      end
    end
    private_class_method :columnize

    def self.equalitize(sign)
      sign.nil? ? EQUALS : sign
    end
    private_class_method :equalitize
  end
end
