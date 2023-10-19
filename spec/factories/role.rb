FactoryBot.define do
  factory :role do
    name { Faker::Name.name }
    description { Faker::Lorem.sentence }

    ApplicationRecords.new('020-role').records.each do |role|
      attrs = role['core'].merge(role.fetch('update', {}))
                          .merge(role.fetch('create', {}))

      factory "role_#{attrs['key']}".downcase.to_sym do
        attrs.each do |k, v|
          send(k.to_sym, v)
        end
      end
    end
  end
end
