require 'rails_helper'

RSpec.describe Invoice, type: :model do
  describe 'relationships' do
    it { should belong_to :customer }
    it { should belong_to :merchant }
    it { should have_many :invoice_items }
    it { should have_many(:items).through(:invoice_items)}
  end

  describe 'instance methods' do
    it '#can_be_deleted?' do
      invoice = create(:invoice)

      expect(invoice.can_be_deleted?).to eq(true)

      items = create_list(:item, 2)
      invoice.invoice_items.create!(item_id: items.first.id)
      invoice.invoice_items.create!(item_id: items.second.id)

      expect(invoice.can_be_deleted?).to eq(false)
    end
  end
end
