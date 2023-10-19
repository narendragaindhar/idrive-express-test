FactoryBot.define do
  factory :order_type do
    ApplicationRecords.new('040-order_type').records.each do |order_type|
      attrs = order_type['core'].merge(order_type.fetch('update', {}))
                                .merge(order_type.fetch('create', {}))

      factory "order_type_#{attrs['key']}".downcase.to_sym do
        attrs.each do |k, v|
          if k == 'product'
            product do
              Product.find_by(v) || association("product_#{v['name']}".downcase.to_sym)
            end
          else
            send(k.to_sym, v)
          end
        end
      end
    end
  end
end
