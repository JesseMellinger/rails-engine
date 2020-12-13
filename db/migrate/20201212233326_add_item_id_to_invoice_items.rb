class AddItemIdToInvoiceItems < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :invoice_items, :items, column: :item_id
  end
end
