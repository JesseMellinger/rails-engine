class FindRevenueFacade
  def self.find_revenue_by_dates(start_date, end_date)
    revenue = FindRevenue.find_revenue_by_dates(start_date, end_date)
    revenue.map do |figure|
      Revenue.new(figure)
    end
  end

  def self.find_revenue_of_merchant(merchant_id)
    revenue = FindRevenue.find_revenue_of_merchant(merchant_id)
    revenue.map do |figure|
      Revenue.new(figure)
    end
  end
end
