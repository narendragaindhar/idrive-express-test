FactoryBot.define do
  factory :address do
    recipient { Faker::Name.name }
    organization { Faker::Company.name }
    address { Faker::Address.street_address }
    city { Faker::Address.city }
    state { [nil, Faker::Address.state, Faker::Address.state_abbr].sample }
    zip { Faker::Address.postcode }
    country { [Faker::Address.country, Faker::Address.country_code].sample }

    factory :address_viawest_1 do
      recipient { 'IDrive' }
      organization { 'Viawest' }
      address { '3935 NW Aloclek Place Bldg. D' }
      city { 'Hillsboro' }
      state { 'OR' }
      zip { '97124' }
      country { 'USA' }
    end

    factory :address_alchemy do
      recipient { 'IDrive' }
      organization { 'Alchemy Communications' }
      address { '6171 W Century Blvd.' }
      city { 'Los Angeles' }
      state { 'CA' }
      zip { '90045' }
      country { 'USA' }
    end

    factory :address_office do
      recipient { 'IDrive Express' }
      organization { 'IDrive' }
      address { '26115 Mureau Road, Suite A' }
      city { 'Calabasas' }
      state { 'CA' }
      zip { '91302' }
      country { 'USA' }
    end

    factory :address_iron_mountain do
      recipient { 'IDrive Inc' }
      organization { 'Iron Mountain Data Center' }
      address { '11680 HAYDEN RD' }
      city { 'MANASSAS' }
      state { 'VA' }
      zip { '20109' }
      country { 'USA' }
    end

    factory :address_viatel do
      recipient { 'IDrive Inc' }
      organization { 'Viatel' }
      address { 'Unit 1, College Business & Technology Park, Bóthar Bhaile Bhlainséir Thuaidh' }
      city { 'Ballycoolen' }
      state { 'Dublin 15' }
      zip { 'D15 PEC4' }
      country { 'Ireland' }
    end
  end
end
