# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create!([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create!(name: 'Emanuel', city: cities.first)
# Environment variables (ENV['...']) can be set in the file config/application.yml.
# See http://railsapps.github.io/rails-environment-variables.html

# Address
address_alchemy_destination = Address.create!(recipient: 'IDrive', organization: 'Alchemy Communications',
                                              address: '6171 W Century Blvd', city: 'Los Angeles',
                                              state: 'CA', zip: '90045', country: 'USA')
address_viawest_1_destination = Address.create!(recipient: 'IDrive', organization: 'Viawest',
                                                address: '3935 NW Aloclek Place Bldg. D',
                                                city: 'Hillsboro', state: 'OR', zip: '97124', country: 'USA')

# Destination
begin
  destination = Destination
rescue NameError
  destination = Datacenter # old model name
end
destination.create!(key: 'alchemy', name: 'Alchemy Datacenter', active: true,
                    address: address_alchemy_destination)
destination.create!(key: 'viawest_1', name: 'Viawest 1 Datacenter', active: true,
                    address: address_viawest_1_destination)

# OrderType
begin
  order_type = OrderType
rescue NameError
  order_type = ExpressKind # old model name
end
order_type_upload = order_type.create!(key: 'upload', name: 'IDrive Express Upload', product_id: 1)

# State
State.create!(order_type: order_type_upload, key: 'upload_order_created',
              percentage: 14, is_drive_event: false, label: 'Order created',
              description: 'Your IDrive Express order has been received',
              public_by_default: true,  notify_by_default: true)
State.create!(order_type: order_type_upload, key: nil, percentage: 28,
              is_drive_event: false, label: 'Shipping label generated',
              description: 'Your shipping information has been generated. Your order will be shipped shortly.',
              public_by_default: false, notify_by_default: false)
State.create!(order_type: order_type_upload, key: nil, percentage: 42,
              is_drive_event: true, label: 'Drive shipped',
              description: 'Your drive has been shipped! Please allow 1-2 weeks for delivery.',
              public_by_default: true, notify_by_default: true)
State.create!(order_type: order_type_upload, key: 'upload_order_drive_return_delayed',
              percentage: 49, is_drive_event: true, label: 'Drive return delayed',
              description: 'It has been a while since your order has shipped. '\
                           'To avoid being charged for the drive, please ship '\
                           'it back to us as soon as possible.',
              public_by_default: true,  notify_by_default: true)
State.create!(order_type: order_type_upload, key: nil, percentage: 56,
              is_drive_event: true, label: 'Drive received at datacenter',
              description: 'We have received your IDrive Express drive. Your data will be uploaded soon!',
              public_by_default: true, notify_by_default: true)
State.create!(order_type: order_type_upload, key: nil, percentage: 70,
              is_drive_event: true, label: 'Drive mounted on server',
              description: 'Your drive has been attached to our servers. Your upload will start soon.',
              public_by_default: false, notify_by_default: false)
State.create!(order_type: order_type_upload, key: nil, percentage: 84,
              is_drive_event: true, label: 'Upload started',
              description: 'Your data upload has begun', public_by_default: true,
              notify_by_default: false)
State.create!(order_type: order_type_upload, key: 'upload_order_upload_restarted',
              percentage: 91, is_drive_event: true, label: 'Upload restarted',
              description: 'Your data upload is still ongoing.',
              public_by_default: false, notify_by_default: false)
State.create!(order_type: order_type_upload, key: 'upload_order_completed',
              percentage: 100, is_drive_event: true, label: 'Upload completed',
              description: 'Your IDrive Express order is complete. You can now access your data in your account!',
              public_by_default: true,  notify_by_default: true)
State.create!(order_type: order_type_upload, key: 'upload_order_drive_never_returned',
              percentage: 100, is_drive_event: true, label: 'Drive never returned',
              description: 'You have been charged due to failure to return your IDrive Express drive back to us.',
              public_by_default: true,  notify_by_default: true)
