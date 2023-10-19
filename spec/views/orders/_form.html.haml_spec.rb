require 'rails_helper'

RSpec.describe 'orders/_form.html.haml', type: :view do
  helper FontAwesome::Rails::IconHelper

  let(:order) { create(:order_upload) }
  let(:drive) { Drive.new }

  before do
    assign(:order, order)
    assign(:drive, drive)
    render
  end

  it 'renders the <form>' do
    expect(rendered).to have_tag('form')
  end

  it 'has an autocomplete <input> for the drive' do
    expect(rendered).to have_tag('input', with: { 'data-autocomplete' => autocomplete_drives_path })
  end

  it 'has a hidden <input> with the drive' do
    expect(rendered).to have_tag('input', with: { type: :hidden, name: 'order[drive_id]' })
  end

  it 'has a <select> with order types' do
    expect(rendered).to have_tag('select', with: { id: 'order_order_type_id' }) do
      with_tag('option', count: 1, text: 'IDrive Express Upload')
    end
  end

  it 'makes the existing drive tab active' do
    expect(rendered).to have_tag('a', with: { class: %w[nav-link active] }, text: 'Existing drive')
  end

  it 'has an autocomplete <input> for the customer' do
    expect(rendered).to have_tag('input', with: { 'data-autocomplete' => autocomplete_customers_path })
  end

  it 'has a hidden <input> with the customer' do
    expect(rendered).to have_tag('input', with: { type: :hidden, name: 'order[customer_id]' })
  end

  it 'has a submit <button>' do
    expect(rendered).to have_tag('button', with: { type: 'submit' })
  end

  context 'with an idrive one order' do
    let(:order) { create(:order_idrive_one) }

    it 'makes the new drive tab active' do
      expect(rendered).to have_tag('a', with: { class: %w[nav-link active] }, text: 'New drive')
    end
  end
end
