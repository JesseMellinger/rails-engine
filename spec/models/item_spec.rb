require 'rails_helper'

RSpec.describe Item, type: :model do
  describe 'relationships' do
    it { should belong_to :merchant }
    it { should have_many :invoice_items }
    it { should have_many(:invoices).through(:invoice_items)}
  end

  describe 'class methods' do
    before :each do
      @merchant = create(:merchant)
      @items = create_list(:item, 3, merchant: @merchant)
    end

    it '.find_by_attribute' do
      expect(Item.find_by_attribute("name", @items.first.name)).to eq(@items.first)
      expect(Item.find_by_attribute("name", @items.second.name)).to eq(@items.second)
      expect(Item.find_by_attribute("description", @items.first.description)).to eq(@items.first)

      expect(Item.find_by_attribute("created_at", @items.first.created_at)).to eq(@items.first)
      expect(Item.find_by_attribute("created_at", @items.second.created_at)).to eq(@items.first)

      @items.first.update!(updated_at: 10.days.from_now)
      expect(Item.find_by_attribute("updated_at", @items.first.updated_at)).to eq(@items.first)
      expect(Item.find_by_attribute("updated_at", @items.second.updated_at)).to eq(@items.second)
    end

    it '.find_all_by_attribute' do
      @items.first.update!(name: "Practical Granite Shirt", description: "Can one desire too much of a good thing?.")
      @items.second.update!(name: "Infinite Star Socks", description: "In my mind's eye.")
      @items.third.update!(name: "Awesome Concrete Watch", description: "Can one admire too much of a good thing?")

      expect(Item.find_all_by_attribute("name", "ITE")).to include(@items.first, @items.second)
      expect(Item.find_all_by_attribute("description", "IrE")).to include(@items.first, @items.third)

      expect(Item.find_all_by_attribute("created_at", @items.first.created_at)).to eq(@items)

      @items.first.update!(updated_at: 10.days.from_now)

      expect(Item.find_all_by_attribute("updated_at", @items.second.updated_at)).to eq([@items.second, @items.third])
    end
  end
end
