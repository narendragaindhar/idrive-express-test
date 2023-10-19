FactoryBot.define do
  factory :product do
    ApplicationRecords.new('010-product').records.each do |product|
      attrs = product['core'].merge(product.fetch('update', {}))
                             .merge(product.fetch('create', {}))

      factory "product_#{attrs['name']}".downcase.to_sym do
        attrs.each do |k, v|
          send(k.to_sym, v)
        end
      end
    end
  end
end
