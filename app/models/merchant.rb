class Merchant < ApplicationRecord
  has_many :items, dependent: :destroy
  has_many :invoices
  has_many :transactions, through: :invoices
  has_many :invoice_items, through: :invoices

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

  def self.most_revenue(quantity)
    joins(items: [{ invoices: :transactions }])
    .select('merchants.*, sum(invoice_items.quantity * invoice_items.unit_price) as total_revenue')
    .merge(Transaction.successful)
    .merge(Invoice.shipped)
    .group(:id)
    .order(total_revenue: :desc)
    .limit(quantity.to_i)
  end

  def self.most_items(quantity)
    joins(items: [{ invoices: :transactions }])
    .select('merchants.*, sum(invoice_items.quantity) as num_of_items_sold')
    .merge(Transaction.successful)
    .merge(Invoice.shipped)
    .group(:id)
    .order(num_of_items_sold: :desc)
    .limit(quantity)
  end
end
