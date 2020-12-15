require 'rails_helper'

RSpec.describe Merchant, type: :model do
  describe 'relationships' do
    it { should have_many :items }
    it { should have_many :invoices }
    it { should have_many(:transactions).through(:invoices) }
    it { should have_many(:invoice_items).through(:invoices) }
  end

  describe 'class methods' do
    before :each do
      @merchants = create_list(:merchant, 3)
    end

    it '.find_by_attribute' do
      @merchants.second.update!(name: "Turing")
      @merchants.third.update!(name: "Ring World")

      expect(Merchant.find_by_attribute("name", "Ing")).to eq(@merchants.second)

      expect(Merchant.find_by_attribute("created_at", @merchants.first.created_at)).to eq(@merchants.first)
      expect(Merchant.find_by_attribute("created_at", @merchants.second.created_at)).to eq(@merchants.first)

      @merchants.first.update!(updated_at: 10.days.from_now)
      expect(Merchant.find_by_attribute("updated_at", @merchants.first.updated_at)).to eq(@merchants.first)
      expect(Merchant.find_by_attribute("updated_at", @merchants.second.updated_at)).to eq(@merchants.second)
    end

    it '.find_all_by_attribute' do
      @merchants.first.update!(name: "Practical Granite Shirt")
      @merchants.second.update!(name: "Infinite Star Socks")
      @merchants.third.update!(name: "Awesome Concrete Watch")

      expect(Merchant.find_all_by_attribute("name", "ITE")).to eq([@merchants.first, @merchants.second])

      expect(Merchant.find_all_by_attribute("created_at", @merchants.first.created_at)).to eq(@merchants)

      @merchants.first.update!(updated_at: 10.days.from_now)

      expect(Merchant.find_all_by_attribute("updated_at", @merchants.second.updated_at)).to eq([@merchants.second, @merchants.third])
    end
  end
end
