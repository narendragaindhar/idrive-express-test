require 'rails_helper'

RSpec.shared_examples 'an autocomplete controller action' do |action, term|
  let(:request) { get(action, params: { term: term }, format: :json) }

  before do
    non_matching_records
  end

  context "when GET ##{action}" do
    it 'is successful' do
      expect(request).to be_successful
    end

    it 'renders the index json' do
      expect(request).to render_template(:index)
    end

    it 'assigns @records' do
      request
      expect(assigns(:records)).to eq(records)
    end

    it 'assigns @label_method' do
      request
      expect(assigns(:label_method)).to eq(:label)
    end
  end
end

RSpec.describe AutocompleteController, type: :controller do
  let(:user) { create(:user) }

  before do
    login_user user
  end

  it_behaves_like 'an autocomplete controller action', :customers, 'Estelle' do
    let(:non_matching_records) do
      create(:customer, email: 'mason_schroeder@oreilly.info',
                        name: 'Thalia Casper', username: 'colton_bergstrom')
    end
    let!(:record) do
      create(:customer, email: 'isaiah.cremin@murphylittle.info',
                        name: 'Estelle Kemmer', username: 'violette.herman')
    end
    let(:records) { [record] }
  end

  it_behaves_like 'an autocomplete controller action', 'drives', '87E23263' do
    let(:non_matching_records) do
      create(:drive, identification_number: '87E23263351FDE7',
                     serial: '03BEA4A7914A8E955', active: false)
      create(:drive, identification_number: '6CCD8061DDB3D4A',
                     serial: 'DDE3EDCCCF0615B1E')
    end
    let!(:record) do
      create(:drive, identification_number: '87E2326368FB166',
                     serial: '7A19E4C7E634D4351')
    end
    let(:records) { [record] }
  end
end
