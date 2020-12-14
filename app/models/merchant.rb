class Merchant < ApplicationRecord
  has_many :items, dependent: :destroy

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
end
