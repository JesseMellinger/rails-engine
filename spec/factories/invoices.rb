FactoryBot.define do
  factory :invoice do
    status { Faker::Kpop.boy_bands }
    customer
    merchant
  end
end
