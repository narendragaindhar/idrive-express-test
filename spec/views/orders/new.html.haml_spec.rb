require 'rails_helper'

RSpec.describe 'orders/new.html.haml', type: :view do
  helper FontAwesome::Rails::IconHelper

  let(:drive) { Drive.new }
  let(:availables) do
    create(:drive)
    create(:drive)
    create(:drive)
    Drive.available
  end
  let(:order) { Order.new }

  before do
    assign(:order, order)
    assign(:available_drives, availables)
    assign(:drive, drive)
    render
  end

  it 'renders the <form>' do
    expect(rendered).to have_tag('form', with: { action: orders_path })
  end
end
