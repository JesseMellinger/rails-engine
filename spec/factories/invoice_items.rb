FactoryBot.define do
  factory :invoice_item do
    quantity { Faker::Number.number(digits: 2) }
    unit_price { Faker::Number.decimal(l_digits: 2, r_digits: 2) }
    item
    invoice
  end
end
