begin
  destination = Destination
rescue NameError
  destination = Datacenter # old model name
end

begin
  destination.find_by! key: 'office'
rescue ActiveRecord::RecordNotFound
  address = Address.create! recipient: 'IDrive Express', organization: 'IDrive',
                            address: '26115 Mureau Road, Suite A', city: 'Calabasas',
                            state: 'CA', zip: '91302', country: 'USA'
  destination.create! key: 'office', name: 'IDrive Office', active: true, address: address
end
