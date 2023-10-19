require 'rails_helper'
require 'will_paginate/array'

RSpec.describe 'orders/_list.html.haml', type: :view do
  include Pundit
  helper DayCountsHelper, FontAwesome::Rails::IconHelper

  let(:order) { build_stubbed(:order, updated_at: Time.zone.now) }
  let(:order_with_day_count) { build_stubbed(:order_with_day_count, updated_at: Time.zone.now) }
  let(:orders) { [order, order_with_day_count].paginate }
  let(:orders_path_sym) { :orders_path }
  let(:params) { {} }
  let(:order_policy_bulk_update?) { false }
  let(:order_policy) { instance_double('OrderPolicy', bulk_update?: order_policy_bulk_update?) }

  before do
    assign(:orders, orders)
    assign(:orders_path_sym, orders_path_sym)
    allow(view).to receive(:params).and_return(params)
    allow(view).to receive(:policy).with(:order).and_return(order_policy)
    render
  end

  it 'does not link to bulk update' do
    expect(rendered).not_to have_tag('a', with: { href: csv_files_path })
  end

  context 'with some orders' do
    it 'displays the given orders' do
      expect(rendered).to match(/##{order.id}/i)
      expect(rendered).to match(/##{order_with_day_count.id}/i)
    end

    it 'displays the order type' do
      expect(rendered).to match(/ #{order.order_type.name} for /i)
      expect(rendered).to match(/ #{order_with_day_count.order_type.name} for /i)
    end

    it 'has a CSV toolbar with some links' do
      expect(rendered).to have_tag('button', text: /CSV/)
      expect(rendered).to have_tag('.dropdown-menu') do
        with_tag('a', text: 'View as CSV', with: { href: orders_path(format: :csv) })
        with_tag('a', text: 'Download as CSV', with: { href: orders_path(download: true, format: :csv) })
      end
    end

    context 'with a search' do
      let(:params) { { q: 'search' } }

      it 'makes sure the csv link includes the search' do
        expect(rendered).to have_tag('a', text: 'View as CSV', with: { href: orders_path(q: 'search', format: :csv) })
        expect(rendered).to have_tag(
          'a', text: 'Download as CSV',
               with: { href: orders_path(q: 'search', download: true, format: :csv) }
        )
      end
    end

    context 'when viewing my orders' do
      let(:orders_path_sym) { :my_orders_path }

      it 'links to CSV within the proper scope' do
        expect(rendered).to have_tag('a', text: 'View as CSV', with: { href: my_orders_path(format: :csv) })
        expect(rendered).to have_tag(
          'a', text: 'Download as CSV',
               with: { href: my_orders_path(download: true, format: :csv) }
        )
      end

      context 'with a search' do
        let(:params) { { q: 'search' } }

        it 'makes sure the csv link includes the search' do
          expect(rendered).to have_tag(
            'a', text: 'View as CSV',
                 with: { href: my_orders_path(q: 'search', format: :csv) }
          )
          expect(rendered).to have_tag(
            'a', text: 'Download as CSV',
                 with: { href: my_orders_path(q: 'search', download: true, format: :csv) }
          )
        end
      end
    end
  end

  context 'with no orders' do
    let(:orders) { [].paginate }

    it 'has disabled links' do
      expect(rendered).to have_tag('span.disabled', text: 'View as CSV')
      expect(rendered).to have_tag('span.disabled', text: 'Download as CSV')
    end
  end

  context 'with too many orders' do
    let(:orders) do
      orders = [].paginate
      call_count = 0
      expect(orders).to receive(:total_entries).at_least(:twice) do
        call_count += 1
        call_count < 3 ? 501 : 0
      end
      orders
    end

    it 'has disabled links' do
      expect(rendered).to have_tag(
        'span.disabled', text: 'View as CSV',
                         with: { title: 'The system cannot process more than 500 '\
                                       'records as CSV. Please filter your search '\
                                       'and try again.' }
      )
      expect(rendered).to have_tag(
        'span.disabled', text: 'Download as CSV',
                         with: { title: 'The system cannot process more than 500 '\
                                       'records as CSV. Please filter your search '\
                                       'and try again.' }
      )
    end
  end

  context 'with an order whose percentage is 100 but `completed_at` has been cleared' do
    let(:orders) do
      order = create(:order_upload)
      user = create(:user, name: 'Jon')
      order.order_states << create(
        :order_state,
        state: create(:state_international_shipping_fee), order: order, user: user,
        comments: 'Thank you for your your interest in using the Express service. '\
                  'Before we process your order, since this is shipping internationally, '\
                  'we wanted to make sure you were aware of the additional shipping '\
                  'costs of the order.'
      )
      order.order_states << create(
        :order_state,
        state: create(:state_upload_cancelled), order: order, user: user,
        comments: 'Your order has been cancelled since you did not approve the shipping fee.'
      )
      order.completed_at = nil # never forget Order #56972
      order.save
      [order].paginate
    end

    it 'shows the last updated time instead of the completed time' do
      expect(rendered).to have_tag('div.text-muted', text: /updated/)
      expect(rendered).not_to have_tag('div.text-muted', text: /completed/)
    end
  end

  context 'with bulk update privileges' do
    let(:order_policy_bulk_update?) { true }

    it 'links to bulk update' do
      expect(rendered).to have_tag('a', with: { href: csv_files_path })
    end
  end
end
