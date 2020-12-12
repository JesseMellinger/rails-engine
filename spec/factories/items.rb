FactoryBot.define do
  factory :item do
    name { Faker::Commerce.product_name }
    description { Faker::Quotes::Shakespeare.hamlet_quote }
    unit_price { Faker::Number.decimal(l_digits: 2, r_digits: 2) }
    merchant
  end
end
