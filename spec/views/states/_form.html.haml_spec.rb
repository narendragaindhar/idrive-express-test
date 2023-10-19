require 'rails_helper'

RSpec.describe 'states/_form.html.haml', type: :view do
  let(:order) { create(:order) }

  before do
    # create some states
    State.find_by(key: 'upload_order_created') || create(:state_initial)
    create(:state_drive_shipped)
    create(:state_upload_completed)

    assign(:order, order)
    assign(:order_state, OrderState.new(order: order))
    render
  end

  it 'has a title' do
    expect(rendered).to have_tag('.card-header', text: /Update order/)
  end

  it 'has a <select> with states' do
    expect(rendered).to have_tag('select#order_state_state_id') do
      with_tag('option', count: 4) # because one is blank
    end
  end

  it 'explains what the #is_public field does' do
    expect(rendered).to have_tag('.form-check-label[title*="IDrive website"]', text: /Update IDrive website\?/)
  end

  context 'with an IBackup upload order' do
    let(:order) { create(:order_ibackup_upload) }

    it 'explains what the #is_public field does' do
      expect(rendered).to have_tag('.form-check-label[title*="IBackup website"]', text: /Update IBackup website\?/)
    end
  end
end
