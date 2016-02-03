require 'rails_helper'

RSpec.describe KitchenStatus do
  describe 'time calculation' do
    examples = [
      {
        current_time: Time.zone.parse('2016-01-18 00:00:00'),
        opening_time: Time.zone.parse('2016-01-18 00:00:00'),
        closing_time: Time.zone.parse('2016-01-20 17:00:00'),
        next_opens:   Time.zone.parse('2016-01-25 00:00:00'),
      },
      {
        current_time: Time.zone.parse('2016-01-19 00:00:00'),
        opening_time: Time.zone.parse('2016-01-18 00:00:00'),
        closing_time: Time.zone.parse('2016-01-20 17:00:00'),
        next_opens:   Time.zone.parse('2016-01-25 00:00:00'),
      },
      {
        current_time: Time.zone.parse('2016-01-20 00:00:00'),
        opening_time: Time.zone.parse('2016-01-18 00:00:00'),
        closing_time: Time.zone.parse('2016-01-20 17:00:00'),
        next_opens:   Time.zone.parse('2016-01-25 00:00:00'),
      },
      {
        current_time: Time.zone.parse('2016-01-21 00:00:00'),
        opening_time: Time.zone.parse('2016-01-18 00:00:00'),
        closing_time: Time.zone.parse('2016-01-20 17:00:00'),
        next_opens:   Time.zone.parse('2016-01-25 00:00:00'),
      },
      {
        current_time: Time.zone.parse('2016-01-22 00:00:00'),
        opening_time: Time.zone.parse('2016-01-18 00:00:00'),
        closing_time: Time.zone.parse('2016-01-20 17:00:00'),
        next_opens:   Time.zone.parse('2016-01-25 00:00:00'),
      },
      {
        current_time: Time.zone.parse('2016-01-23 00:00:00'),
        opening_time: Time.zone.parse('2016-01-18 00:00:00'),
        closing_time: Time.zone.parse('2016-01-20 17:00:00'),
        next_opens:   Time.zone.parse('2016-01-25 00:00:00'),
      },
      {
        current_time: Time.zone.parse('2016-01-24 00:00:00'),
        opening_time: Time.zone.parse('2016-01-18 00:00:00'),
        closing_time: Time.zone.parse('2016-01-20 17:00:00'),
        next_opens:   Time.zone.parse('2016-01-25 00:00:00'),
      },
      {
        current_time: Time.zone.parse('2016-01-25 00:00:00'),
        opening_time: Time.zone.parse('2016-01-25 00:00:00'),
        closing_time: Time.zone.parse('2016-01-27 17:00:00'),
        next_opens:   Time.zone.parse('2016-02-01 00:00:00'),
      },
    ]
    examples.each do |ex|
      it 'indicates correct opening time when current time is #{ex[:current_time]}' do
        ks = described_class.new
        Timecop.travel(ex[:current_time]) do
          expect(ks.opening_time).to eql(ex[:opening_time])
        end
      end
      it 'indicates correct closing time when current time is #{ex[:current_time]}' do
        ks = described_class.new
        Timecop.travel(ex[:current_time]) do
          expect(ks.closing_time).to eql(ex[:closing_time])
        end
      end
      it 'indicates correct next opening time when current time is #{ex[:current_time]}' do
        ks = described_class.new
        Timecop.travel(ex[:current_time]) do
          expect(ks.next_opens).to eql(ex[:next_opens])
        end
      end
    end
  end

  it 'is open between opening_time and closing_time, and not open before or after' do
    ks = described_class.new
    Timecop.travel(ks.opening_time - 1.second) do
      expect(ks).to_not be_open
    end
    Timecop.travel(ks.opening_time) do
      expect(ks).to be_open
    end
    Timecop.travel(ks.closing_time - 1.second) do
      expect(ks).to be_open
    end
    Timecop.travel(ks.closing_time + 1.second) do
      expect(ks).to_not be_open
    end
  end

  it 'responds to the override' do
    always_open = described_class.new('open')
    always_closed = described_class.new('closed')
    Timecop.travel(always_open.opening_time - 1.second) do
      expect(always_open).to be_open
      expect(always_closed).to_not be_open
    end
    Timecop.travel(always_open.opening_time) do
      expect(always_open).to be_open
      expect(always_closed).to_not be_open
    end
    Timecop.travel(always_open.closing_time - 1.second) do
      expect(always_open).to be_open
      expect(always_closed).to_not be_open
    end
    Timecop.travel(always_open.closing_time + 1.second) do
      expect(always_open).to be_open
      expect(always_closed).to_not be_open
    end
  end
end