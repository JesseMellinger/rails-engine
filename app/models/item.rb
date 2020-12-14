class Item < ApplicationRecord
  before_destroy :destroy_invoices

  belongs_to :merchant
  has_many :invoice_items
  has_many :invoices, through: :invoice_items

  def self.find_by_attribute(attribute, value)
    if attribute == "created_at" || attribute == "updated_at"
      where("Date(#{attribute}) = ?", "#{value}").first
    else
      where("lower(#{attribute}) like ?", "%#{value.downcase}%").first
    end
  end

  def self.find_all_by_attribute(attribute, value)
    if attribute == "created_at" || attribute == "updated_at"
      where("Date(#{attribute}) = ?", "#{value}")
    else
      where("lower(#{attribute}) like ?", "%#{value.downcase}%")
    end
  end

  private
  def destroy_invoices
    self.invoices.each do |invoice|
      invoice_item = InvoiceItem.find_record(self.id, invoice.id)
      InvoiceItem.delete(invoice_item.id)
      Invoice.delete(invoice.id) if invoice.can_be_deleted?
    end
  end
end
