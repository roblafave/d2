require 'rails_helper'

# See http://stackoverflow.com/a/20010923 for this method
#   of testing concerns

RSpec.shared_examples_for "spree order concerns" do
  # the class that includes the concern
  let(:model) { described_class }
  let(:address) { FactoryGirl.build(:address) }

  describe "address validation" do
    let(:ship_address) { FactoryGirl.create(:address) }
    let(:bill_address) { FactoryGirl.create(:address, zipcode: "90210", postal_code: nil) }
    let(:order) { FactoryGirl.build(:order_ready_to_ship, ship_address: ship_address, bill_address: bill_address)}

    it 'requires a ship_address with an assigned postal_code' do
      expect(ship_address).to be_valid
      expect(ship_address.postal_code).to be_present
      expect(order).to be_valid
      order.ship_address = order.bill_address
      expect(order).to_not be_valid
      expect(order.errors[:ship_address]).to be_present
    end

    it 'allows a valid bill_address without an assigned postal_code' do
      expect(bill_address).to be_valid
      expect(bill_address.zipcode).to be_present
      expect(bill_address.postal_code).to be_blank
      expect(order).to be_valid
    end
  end

  describe "tote tags for completed orders" do
    let(:order) { FactoryGirl.create(:order_ready_to_ship) }

    it 'generates a single tag with complete information' do
      expect(order.quantity).to be <= 3

      tote_tags = order.tote_tags
      expect(tote_tags.size).to eq(1)

      tag = tote_tags.first
      expect(tag.order_number).to    eq(order.number)
      expect(tag.tag_number).to      eq(1)
      expect(tag.name).to            eq(order.name)
      expect(tag.address1).to        eq(order.ship_address.address1)
      expect(tag.address2).to        eq(order.ship_address.address2)
      expect(tag.city).to            eq(order.ship_address.city)
      expect(tag.state).to           eq(order.ship_address.state.abbr)
      expect(tag.zipcode).to         eq(order.ship_address.zipcode)
      expect(tag.phone).to           eq(order.ship_address.phone)
      expect(tag.instructions).to    eq(order.special_instructions)
      expect(tag.delivery_window).to eq(order.shipments.first.selected_delivery_window)

      expect(tag.packing_list.size).to eq(1)
    end

    it 'generates additional tags without line items for orders with many items' do
      7.times { |n| FactoryGirl.create(:line_item, order: order) }
      order.line_items.reload
      order.update!

      expect(order.quantity).to eq(8) # original item, plus 7

      tote_tags = order.tote_tags
      expect(tote_tags.size).to eq(3) # 3 items per tag, the last may not be full

      # All tags should contain delivery information
      tote_tags.each_with_index do |tag, i|
        expect(tag.order_number).to    eq(order.number)
        expect(tag.tag_number).to      eq(i + 1)
        expect(tag.name).to            eq(order.name)
        expect(tag.address1).to        eq(order.ship_address.address1)
        expect(tag.address2).to        eq(order.ship_address.address2)
        expect(tag.city).to            eq(order.ship_address.city)
        expect(tag.state).to           eq(order.ship_address.state.abbr)
        expect(tag.zipcode).to         eq(order.ship_address.zipcode)
        expect(tag.phone).to           eq(order.ship_address.phone)
        expect(tag.instructions).to    eq(order.special_instructions)
        expect(tag.delivery_window).to eq(order.shipments.first.selected_delivery_window)
      end

      # Only first tag should include packing list
      first_tag = tote_tags.shift
      expect(first_tag.packing_list.size).to eq(8) # number of unique line items
      tote_tags.each do |tag|
        expect(tag.packing_list).to be_empty
      end
    end
  end
end
