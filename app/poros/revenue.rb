class Revenue
  attr_reader :id,
              :revenue

  def initialize(figure)
    @id = nil
    @revenue = figure
  end
end
