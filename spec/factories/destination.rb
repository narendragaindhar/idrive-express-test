FactoryBot.define do
  factory :destination do
    ApplicationRecords.new('030-destination').records.each do |destination|
      attrs = destination['core'].merge(destination.fetch('update', {}))
                                 .merge(destination.fetch('create', {}))

      factory "destination_#{attrs['key']}".downcase.to_sym do
        attrs.each do |k, v|
          if k == 'address'
            association :address, factory: "address_#{attrs['key']}".downcase.to_sym
          else
            send(k.to_sym, v)
          end
        end
      end
    end
  end
end
