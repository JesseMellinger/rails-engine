class FindRevenue
  def initialize(start_date, end_date)
    @start_date = start_date
    @end_date = end_date
  end

  def find_revenue_by_dates()
    connection = ActiveRecord::Base.connection
    sql = "SELECT sum(invoice_items.quantity * invoice_items.unit_price) as revenue FROM merchants INNER JOIN items ON items.merchant_id = merchants.id INNER JOIN invoice_items ON invoice_items.item_id = items.id INNER JOIN invoices ON invoices.id = invoice_items.invoice_id INNER JOIN transactions ON transactions.invoice_id = invoices.id WHERE (transactions.result = 'success' and invoices.status = 'shipped' and Date(invoices.created_at) >= '#{@start_date}' and Date(invoices.created_at) <= '#{@end_date}')"
    connection.select_values(sql)
  end
end
