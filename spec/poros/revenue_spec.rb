require "rails_helper"

RSpec.describe Revenue do
  it "exists" do
    figure = Faker::Number.number(digits: 3)

    revenue = Revenue.new(figure)

    expect(revenue).to be_a Revenue
    expect(revenue.id).to be_nil
    expect(revenue.revenue).to eq(figure)
  end
end
