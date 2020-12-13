require 'rails_helper'

RSpec.describe InvoiceItem, type: :model do
  describe 'relationships' do
    it { should belong_to :item }
    it { should belong_to :invoice }
  end

  describe 'class methods' do
    it '.find_record' do
      items = create_list(:item, 3)
      invoice = create(:invoice)

      invoice.invoice_items.create!(item_id: items.second.id)
      invoice.invoice_items.create!(item_id: items.third.id)

      expect(InvoiceItem.find_record(items.second.id, invoice.id)).to eq(InvoiceItem.first)
      expect(InvoiceItem.find_record(items.third.id, invoice.id)).to eq(InvoiceItem.second)
    end
  end
end
