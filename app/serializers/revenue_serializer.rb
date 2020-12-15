class RevenueSerializer
  include FastJsonapi::ObjectSerializer
  attributes :name
  def self.serialize(revenue)
  {
    "data": {
      "id": 'null',
      "attributes": {
        "revenue": revenue
      }
    }
  }
  end
end
