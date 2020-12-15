FactoryBot.define do
  factory :transaction do
    credit_card_number { Faker::Business.credit_card_number }
    credit_card_expiration_date { '04/23' }
    result { 'success' }
    invoice
  end
end
