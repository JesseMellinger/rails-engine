require 'rails_helper'

describe FindRevenueFacade do
  context "class methods" do
    context ".find_revenue_by_dates" do
      it "returns revenue object in array of given dates" do
        result = FindRevenueFacade.find_revenue_by_dates(Time.now.to_s, Time.now.to_s)
        expect(result).to be_a(Array)
        expect(result.first).to be_a(Revenue)
        expect(result.count).to eq(1)
      end
    end

    context ".find_revenue_of_merchant" do
      it "returns revenue object in array for given merchant" do
        merchant = create(:merchant)
        result = FindRevenueFacade.find_revenue_of_merchant(merchant.id)
        expect(result).to be_a(Array)
        expect(result.first).to be_a(Revenue)
        expect(result.count).to eq(1)
      end
    end
  end
end
