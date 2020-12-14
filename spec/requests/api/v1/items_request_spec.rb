require 'rails_helper'

describe "Items API" do
  it "sends a list of all items" do
    create_list(:item, 3)

    get '/api/v1/items'

    expect(response).to be_successful

    items = JSON.parse(response.body, symbolize_names: true)

    expect(items[:data].count).to eq(3)

    items[:data].each do |item|
      expect(item).to have_key(:id)
      expect(item[:id]).to be_an(String)

      expect(item).to have_key(:type)
      expect(item[:type]).to eq("item")

      expect(item).to have_key(:attributes)
      expect(item[:attributes]).to be_a(Hash)

      expect(item[:attributes]).to have_key(:name)
      expect(item[:attributes][:name]).to be_a(String)

      expect(item[:attributes]).to have_key(:description)
      expect(item[:attributes][:description]).to be_a(String)

      expect(item[:attributes]).to have_key(:unit_price)
      expect(item[:attributes][:unit_price]).to be_a(Float)

      expect(item[:attributes]).to have_key(:merchant_id)
      expect(item[:attributes][:merchant_id]).to be_a(Integer)
    end
  end

  it "can get one item by its id" do
    id = create(:item).id

    get "/api/v1/items/#{id}"

    item = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful

    expect(item[:data]).to have_key(:id)
    expect(item[:data][:id]).to eq(id.to_s)

    expect(item[:data]).to have_key(:type)
    expect(item[:data][:type]).to eq("item")

    expect(item[:data]).to have_key(:attributes)
    expect(item[:data][:attributes]).to be_a(Hash)

    expect(item[:data][:attributes]).to have_key(:name)
    expect(item[:data][:attributes][:name]).to be_a(String)

    expect(item[:data][:attributes]).to have_key(:description)
    expect(item[:data][:attributes][:description]).to be_a(String)

    expect(item[:data][:attributes]).to have_key(:unit_price)
    expect(item[:data][:attributes][:unit_price]).to be_a(Float)

    expect(item[:data][:attributes]).to have_key(:merchant_id)
    expect(item[:data][:attributes][:merchant_id]).to be_a(Integer)
  end

  it "can create a new item" do
    merchant_id = create(:merchant).id

    item_params = ({
                    name: Faker::Commerce.product_name,
                    description: Faker::Quotes::Shakespeare.hamlet_quote ,
                    unit_price: Faker::Number.decimal(l_digits: 2, r_digits: 2),
                    merchant_id: merchant_id,
                  })
    headers = {"CONTENT_TYPE" => "application/json"}

    post "/api/v1/items", headers: headers, params: JSON.generate(item_params)

    created_item = Item.last

    expect(response).to be_successful
    expect(created_item.name).to eq(item_params[:name])
    expect(created_item.description).to eq(item_params[:description])
    expect(created_item.unit_price).to eq(item_params[:unit_price])
    expect(created_item.merchant_id).to eq(item_params[:merchant_id])
  end

  it "can update an existing item" do
    id = create(:item).id
    previous_name = Item.last.name

    item_params = { name: Faker::Commerce.product_name }
    headers = {"CONTENT_TYPE" => "application/json"}

    patch "/api/v1/items/#{id}", headers: headers, params: JSON.generate(item_params)
    item = Item.find_by(id: id)

    expect(response).to be_successful
    expect(item.name).to_not eq(previous_name)
    expect(item.name).to eq(item_params[:name])
  end

  it "can destroy an item" do
    item = create(:item)

    expect{ delete "/api/v1/items/#{item.id}" }.to change(Item, :count).by(-1)

    expect(response).to be_successful
    expect{Item.find(item.id)}.to raise_error(ActiveRecord::RecordNotFound)
  end

  it "can destroy an item's invoice items and invoices if invoice has no items attached" do
    customer = create(:customer)
    merchant = create(:merchant)
    item = create(:item, merchant: merchant)

    customer.invoices.create!(merchant_id: merchant.id)
    customer.invoices.create!(merchant_id: merchant.id)
    customer.invoices.create!(merchant_id: merchant.id)
    customer.invoices.create!(merchant_id: merchant.id)
    customer.invoices.create!(merchant_id: merchant.id)

    item.invoice_items.create!(invoice_id: Invoice.first.id)
    item.invoice_items.create!(invoice_id: Invoice.second.id)
    item.invoice_items.create!(invoice_id: Invoice.third.id)
    item.invoice_items.create!(invoice_id: Invoice.fourth.id)
    item.invoice_items.create!(invoice_id: Invoice.fifth.id)

    expect(InvoiceItem.count).to eq(5)
    expect(Invoice.count).to eq(5)

    expect{ delete "/api/v1/items/#{item.id}" }.to change(Item, :count).by(-1)

    expect(response).to be_successful
    expect(InvoiceItem.count).to eq(0)
    expect(Invoice.count).to eq(0)

    item.invoice_items.all? do |invoice_item|
      expect{InvoiceItem.find(invoice_item.id)}.to raise_error(ActiveRecord::RecordNotFound)
    end

    item.invoices.all? do |invoice|
      expect{Invoice.find(invoice.id)}.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  it 'returns all items associated with a merchant' do
    merchant = create(:merchant)
    items = create_list(:item, 5, merchant: merchant)

    get "/api/v1/merchants/#{merchant.id}/items"

    items = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful

    expect(items[:data].count).to eq(5)

    items[:data].each do |item|
      expect(item).to have_key(:id)
      expect(item[:id]).to be_an(String)

      expect(item).to have_key(:type)
      expect(item[:type]).to eq("item")

      expect(item).to have_key(:attributes)
      expect(item[:attributes]).to be_a(Hash)

      expect(item[:attributes]).to have_key(:name)
      expect(item[:attributes][:name]).to be_a(String)

      expect(item[:attributes]).to have_key(:description)
      expect(item[:attributes][:description]).to be_a(String)

      expect(item[:attributes]).to have_key(:unit_price)
      expect(item[:attributes][:unit_price]).to be_a(Float)

      expect(item[:attributes]).to have_key(:merchant_id)
      expect(item[:attributes][:merchant_id]).to eq(merchant.id)
    end
  end

  it 'finds a single record that matches a set of criteria with partial strings and case insensitivity' do
    merchant = create(:merchant)
    items = create_list(:item, 2, merchant: merchant)

    get "/api/v1/items/find?name=#{items.first.name}"

    item = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful

    expect(item[:data]).to be_a(Hash)

    expect(item[:data]).to have_key(:id)
    expect(item[:data][:id]).to eq(items.first.id.to_s)

    expect(item[:data]).to have_key(:type)
    expect(item[:data][:type]).to eq("item")

    expect(item[:data]).to have_key(:attributes)
    expect(item[:data][:attributes]).to be_a(Hash)

    expect(item[:data][:attributes]).to have_key(:name)
    expect(item[:data][:attributes][:name]).to eq(items.first.name)

    expect(item[:data][:attributes]).to have_key(:description)
    expect(item[:data][:attributes][:description]).to eq(items.first.description)

    expect(item[:data][:attributes]).to have_key(:unit_price)
    expect(item[:data][:attributes][:unit_price]).to eq(items.first.unit_price)

    expect(item[:data][:attributes]).to have_key(:merchant_id)
    expect(item[:data][:attributes][:merchant_id]).to eq(items.first.merchant_id)

    description = "Can one desire too much of a good thing?."
    items.first.update!(description: description)
    items.second.update!(description: "Can one admire too much of a good thing?")

    get "/api/v1/items/find?description=Ire"

    item = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful

    expect(item[:data]).to be_a(Hash)

    expect(item[:data]).to have_key(:id)
    expect(item[:data][:id]).to eq(items.first.id.to_s)

    expect(item[:data]).to have_key(:type)
    expect(item[:data][:type]).to eq("item")

    expect(item[:data]).to have_key(:attributes)
    expect(item[:data][:attributes]).to be_a(Hash)

    expect(item[:data][:attributes]).to have_key(:name)
    expect(item[:data][:attributes][:name]).to eq(items.first.name)

    expect(item[:data][:attributes]).to have_key(:description)
    expect(item[:data][:attributes][:description]).to eq(items.first.description)

    expect(item[:data][:attributes]).to have_key(:unit_price)
    expect(item[:data][:attributes][:unit_price]).to eq(items.first.unit_price)

    expect(item[:data][:attributes]).to have_key(:merchant_id)
    expect(item[:data][:attributes][:merchant_id]).to eq(items.first.merchant_id)
  end

  it 'finds a single record by timestamps' do
    items = create_list(:item, 3)

    get "/api/v1/items/find?created_at=#{items.second.created_at}"

    item = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful

    expect(item[:data]).to be_a(Hash)

    expect(item[:data]).to have_key(:id)
    expect(item[:data][:id]).to eq(items.first.id.to_s)

    expect(item[:data]).to have_key(:type)
    expect(item[:data][:type]).to eq("item")

    expect(item[:data]).to have_key(:attributes)
    expect(item[:data][:attributes]).to be_a(Hash)

    expect(item[:data][:attributes]).to have_key(:name)
    expect(item[:data][:attributes][:name]).to eq(items.first.name)

    expect(item[:data][:attributes]).to have_key(:description)
    expect(item[:data][:attributes][:description]).to eq(items.first.description)

    expect(item[:data][:attributes]).to have_key(:unit_price)
    expect(item[:data][:attributes][:unit_price]).to eq(items.first.unit_price)

    expect(item[:data][:attributes]).to have_key(:merchant_id)
    expect(item[:data][:attributes][:merchant_id]).to eq(items.first.merchant_id)

    items.first.update!(updated_at: 10.days.from_now)

    get "/api/v1/items/find?updated_at=#{items.second.updated_at}"

    item = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful

    expect(item[:data]).to be_a(Hash)

    expect(item[:data]).to have_key(:id)
    expect(item[:data][:id]).to eq(items.second.id.to_s)

    expect(item[:data]).to have_key(:type)
    expect(item[:data][:type]).to eq("item")

    expect(item[:data]).to have_key(:attributes)
    expect(item[:data][:attributes]).to be_a(Hash)

    expect(item[:data][:attributes]).to have_key(:name)
    expect(item[:data][:attributes][:name]).to eq(items.second.name)

    expect(item[:data][:attributes]).to have_key(:description)
    expect(item[:data][:attributes][:description]).to eq(items.second.description)

    expect(item[:data][:attributes]).to have_key(:unit_price)
    expect(item[:data][:attributes][:unit_price]).to eq(items.second.unit_price)

    expect(item[:data][:attributes]).to have_key(:merchant_id)
    expect(item[:data][:attributes][:merchant_id]).to eq(items.second.merchant_id)
  end

  it 'finds all records that match a set of criteria with partial strings and case insensitivity' do
    merchant = create(:merchant)
    items = create_list(:item, 3, merchant: merchant)

    items.first.update!(name: "Practical Granite Shirt", description: "Can one desire too much of a good thing?.")
    items.second.update!(name: "Infinite Star Socks", description: "In my mind's eye.")
    items.third.update!(name: "Awesome Concrete Watch", description: "Can one admire too much of a good thing?")

    get "/api/v1/items/find_all?name=ITE"

    item_response = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful

    expect(item_response[:data]).to be_an(Array)
    expect(item_response[:data].count).to eq(2)

    expect(item_response[:data].first[:id]).to eq(items.first.id.to_s)
    expect(item_response[:data].last[:id]).to eq(items.second.id.to_s)

    item_response[:data].each do |item|
      expect(item).to have_key(:type)
      expect(item[:type]).to eq("item")

      expect(item).to have_key(:attributes)
      expect(item[:attributes]).to be_a(Hash)

      expect(item[:attributes]).to have_key(:name)
      expect(item[:attributes][:name]).to be_a(String)

      expect(item[:attributes]).to have_key(:description)
      expect(item[:attributes][:description]).to be_a(String)

      expect(item[:attributes]).to have_key(:unit_price)
      expect(item[:attributes][:unit_price]).to be_a(Float)

      expect(item[:attributes]).to have_key(:merchant_id)
      expect(item[:attributes][:merchant_id]).to eq(merchant.id)
    end

    get "/api/v1/items/find_all?description=IrE"

    item_response = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful

    expect(item_response[:data]).to be_an(Array)
    expect(item_response[:data].count).to eq(2)

    expect(item_response[:data].first[:id]).to eq(items.first.id.to_s)
    expect(item_response[:data].last[:id]).to eq(items.third.id.to_s)

    item_response[:data].each do |item|
      expect(item).to have_key(:type)
      expect(item[:type]).to eq("item")

      expect(item).to have_key(:attributes)
      expect(item[:attributes]).to be_a(Hash)

      expect(item[:attributes]).to have_key(:name)
      expect(item[:attributes][:name]).to be_a(String)

      expect(item[:attributes]).to have_key(:description)
      expect(item[:attributes][:description]).to be_a(String)

      expect(item[:attributes]).to have_key(:unit_price)
      expect(item[:attributes][:unit_price]).to be_a(Float)

      expect(item[:attributes]).to have_key(:merchant_id)
      expect(item[:attributes][:merchant_id]).to eq(merchant.id)
    end
  end

  it 'finds all records by timestamps' do
    merchant = create(:merchant)
    items = create_list(:item, 3, merchant: merchant)

    get "/api/v1/items/find_all?created_at=#{items.second.created_at}"

    item_response = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful

    expect(item_response[:data]).to be_an(Array)
    expect(item_response[:data].count).to eq(3)

    expect(item_response[:data].first[:id]).to eq(items.first.id.to_s)
    expect(item_response[:data].second[:id]).to eq(items.second.id.to_s)
    expect(item_response[:data].third[:id]).to eq(items.third.id.to_s)

    item_response[:data].each do |item|
      expect(item).to have_key(:type)
      expect(item[:type]).to eq("item")

      expect(item).to have_key(:attributes)
      expect(item[:attributes]).to be_a(Hash)

      expect(item[:attributes]).to have_key(:name)
      expect(item[:attributes][:name]).to be_a(String)

      expect(item[:attributes]).to have_key(:description)
      expect(item[:attributes][:description]).to be_a(String)

      expect(item[:attributes]).to have_key(:unit_price)
      expect(item[:attributes][:unit_price]).to be_a(Float)

      expect(item[:attributes]).to have_key(:merchant_id)
      expect(item[:attributes][:merchant_id]).to eq(merchant.id)
    end

    items.first.update!(updated_at: 10.days.from_now)

    get "/api/v1/items/find_all?updated_at=#{items.second.updated_at}"

    item_response = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful

    expect(item_response[:data]).to be_a(Array)
    expect(item_response[:data].count).to eq(2)

    expect(item_response[:data].first[:id]).to eq(items.second.id.to_s)
    expect(item_response[:data].last[:id]).to eq(items.third.id.to_s)

    item_response[:data].each do |item|
      expect(item).to have_key(:type)
      expect(item[:type]).to eq("item")

      expect(item).to have_key(:attributes)
      expect(item[:attributes]).to be_a(Hash)

      expect(item[:attributes]).to have_key(:name)
      expect(item[:attributes][:name]).to be_a(String)

      expect(item[:attributes]).to have_key(:description)
      expect(item[:attributes][:description]).to be_a(String)

      expect(item[:attributes]).to have_key(:unit_price)
      expect(item[:attributes][:unit_price]).to be_a(Float)

      expect(item[:attributes]).to have_key(:merchant_id)
      expect(item[:attributes][:merchant_id]).to eq(merchant.id)
    end
  end
end
