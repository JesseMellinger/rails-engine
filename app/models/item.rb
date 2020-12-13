class Item < ApplicationRecord
  before_destroy :destroy_invoices

  belongs_to :merchant
  has_many :invoice_items
  has_many :invoices, through: :invoice_items

  private
  def destroy_invoices
    self.invoices.each do |invoice|
      invoice_item = InvoiceItem.find_record(self.id, invoice.id)
      InvoiceItem.delete(invoice_item.id)
      Invoice.delete(invoice.id) if invoice.can_be_deleted?
    end
  end
end
