module Readonly
  class Query < Readonly::ApplicationRecord
    def self.exec_query(query)
      connection.exec_query(query)
    end
  end
end
