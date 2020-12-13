class InvoiceItem < ApplicationRecord
  belongs_to :item
  belongs_to :invoice

  def self.find_record(item_id, invoice_id)
    InvoiceItem.where("item_id = ? and invoice_id = ?", item_id, invoice_id).first
  end
end
