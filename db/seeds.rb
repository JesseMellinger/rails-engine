# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require 'csv'

csv_text = File.read(Rails.root.join('db', 'data', 'items.csv'))
csv = CSV.parse(csv_text, :headers => true, :encoding => 'ISO-8859-1')
csv.each do |row|
  i = Item.new
  i.id = row['id']
  i.name = row['name']
  i.description = row['description']
  i.unit_price = (row['unit_price'].to_i/100.0)
  i.merchant_id = row['merchant_id']
  i.created_at = row['created_at']
  i.updated_at = row['updated_at']
  i.save
end

ActiveRecord::Base.connection.tables.each do |t|
  ActiveRecord::Base.connection.reset_pk_sequence!(t)
end
