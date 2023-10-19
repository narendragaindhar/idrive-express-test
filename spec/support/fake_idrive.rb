require 'sinatra/base'

class FakeIDrive < Sinatra::Base
  post '/*' do
    if params['order_id'].present? &&
       params.key?('description') &&
       params['percentage'].present?
      status 200
      content_type 'text/plain', charset: 'ISO-8859'
      response_body 'update_order_status/success.json'
    else
      status 400
      ''
    end
  end

  private

  def response_body(file_name)
    File.open("#{File.dirname(File.dirname(__FILE__))}/fixtures/fake_idrive/#{file_name}", 'rb').read
  end
end
