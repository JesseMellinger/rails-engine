class RevenueSerializer
  def self.serialize(result)
  {
    "data": {
      "id": nil,
      "attributes": {
        "revenue": result
      }
    }
  }
  end
end
