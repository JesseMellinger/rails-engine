require 'rails_helper'

describe 'business intelligence' do
  before :each do
    @m1, @m2, @m3, @m4, @m5, @m6 = create_list(:merchant, 6)

    @it1 = create(:item, unit_price: 1.0, merchant: @m1)
    @it2 = create(:item, unit_price: 2.0, merchant: @m1)
    @it3 = create(:item, unit_price: 3.0, merchant: @m2)
    @it4 = create(:item, unit_price: 4.0, merchant: @m3)
    @it5 = create(:item, unit_price: 1.0, merchant: @m3)
    @it6 = create(:item, unit_price: 1.0, merchant: @m4)
    @it7 = create(:item, unit_price: 5.0, merchant: @m4)
    @it8 = create(:item, unit_price: 6.0, merchant: @m4)
    @it9 = create(:item, unit_price: 6.0, merchant: @m5)
    @it10 = create(:item, unit_price: 7.0, merchant: @m6)

    @inv1 = create(:invoice, status: 'shipped', merchant: @m1)
    @inv2 = create(:invoice, status: 'shipped', merchant: @m1)
    @inv3 = create(:invoice, status: 'shipped', merchant: @m1)
    @inv4 = create(:invoice, status: 'shipped', merchant: @m2)
    @inv5 = create(:invoice, status: 'packaged', merchant: @m2)
    @inv6 = create(:invoice, status: 'shipped', merchant: @m3)
    @inv7 = create(:invoice, status: 'shipped', merchant: @m4)
    @inv8 = create(:invoice, status: 'packaged', merchant: @m5)
    @inv9 = create(:invoice, status: 'shipped', merchant: @m5)
    @inv10 = create(:invoice, status: 'shipped', merchant: @m6)
    @inv11 = create(:invoice, status: 'shipped', merchant: @m6)

    # Merchant 1
      # Invoice Items
    @it1.invoice_items.create!(invoice: @inv1, quantity: 5, unit_price: @it1.unit_price)
    @it2.invoice_items.create!(invoice: @inv2, quantity: 10, unit_price: @it2.unit_price)
    @it2.invoice_items.create!(invoice: @inv3, quantity: 11, unit_price: @it2.unit_price)
      # Transactions
    create(:transaction, invoice: @inv1)
    create(:transaction, invoice: @inv2)
    create(:transaction, invoice: @inv3)
      # Total Revenue
    @m1_tr = @m1.invoice_items.reduce(0) do |coll, ii|
      coll += ii.quantity * ii.unit_price
      coll
    end

    # Merchant 2
      # Invoice Items
    @it3.invoice_items.create!(invoice: @inv4, quantity: 4, unit_price: @it3.unit_price)
    @it3.invoice_items.create!(invoice: @inv5, quantity: 12, unit_price: @it3.unit_price)
      # Transactions
    create(:transaction, invoice: @inv4)
    create(:transaction, invoice: @inv5)
      # Total Revenue
    @m2_tr = @inv4.invoice_items.sum do |ii|
      ii.quantity * ii.unit_price
    end

    # Merchant 3
      # Invoice Items
    @it4.invoice_items.create!(invoice: @inv6, quantity: 14, unit_price: @it4.unit_price)
    @it5.invoice_items.create!(invoice: @inv6, quantity: 6, unit_price: @it5.unit_price)
      # Transactions
    create(:transaction, invoice: @inv6, result: 'failed')

    # Merchant 4
      # Invoice Items
    @it6.invoice_items.create!(invoice: @inv7, quantity: 15, unit_price: @it6.unit_price)
    @it7.invoice_items.create!(invoice: @inv7, quantity: 1, unit_price: @it7.unit_price)
    @it8.invoice_items.create!(invoice: @inv7, quantity: 3, unit_price: @it8.unit_price)
      # Transactions
    create(:transaction, invoice: @inv7)
      # Total Revenue
    @m4_tr = @m4.invoice_items.reduce(0) do |coll, ii|
      coll += ii.quantity * ii.unit_price
      coll
    end

    # Merchant 5
      # Invoice Items
    @it9.invoice_items.create!(invoice: @inv8, quantity: 23, unit_price: @it9.unit_price)
    @it9.invoice_items.create!(invoice: @inv9, quantity: 5, unit_price: @it9.unit_price)
      # Transactions
    create(:transaction, invoice: @inv8)
    create(:transaction, invoice: @inv9, result: 'failed')

    # Merchant 6
      # Invoice Items
    @it10.invoice_items.create!(invoice: @inv10, quantity: 13, unit_price: @it10.unit_price)
    @it10.invoice_items.create!(invoice: @inv11, quantity: 2, unit_price: @it10.unit_price)
      # Transactions
    create(:transaction, invoice: @inv10)
    create(:transaction, invoice: @inv11)
      # Total Revenue
    @m6_tr = @m6.invoice_items.reduce(0) do |coll, ii|
      coll += ii.quantity * ii.unit_price
      coll
    end
  end

  it 'returns a variable number of merchants ranked by total revenue' do
    get '/api/v1/merchants/most_revenue?quantity=3'

    merchants = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful

    expect(merchants[:data]).to be_an(Array)
    expect(merchants[:data].count).to eq(3)

    expect(merchants[:data].first[:id]).to eq(@m6.id.to_s)
    expect(merchants[:data].second[:id]).to eq(@m1.id.to_s)
    expect(merchants[:data].third[:id]).to eq(@m4.id.to_s)

    merchants[:data].each do |merchant|
      expect(merchant).to have_key(:type)
      expect(merchant[:type]).to eq("merchant")

      expect(merchant).to have_key(:attributes)
      expect(merchant[:attributes]).to be_a(Hash)

      expect(merchant[:attributes]).to have_key(:name)
      expect(merchant[:attributes][:name]).to be_a(String)
    end
  end

  it 'returns a variable number of merchants ranked by total number of items sold' do
    get '/api/v1/merchants/most_items?quantity=3'

    merchants = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful

    expect(merchants[:data]).to be_an(Array)
    expect(merchants[:data].count).to eq(3)

    expect(merchants[:data].first[:id]).to eq(@m1.id.to_s)
    expect(merchants[:data].second[:id]).to eq(@m4.id.to_s)
    expect(merchants[:data].third[:id]).to eq(@m6.id.to_s)

    merchants[:data].each do |merchant|
      expect(merchant).to have_key(:type)
      expect(merchant[:type]).to eq("merchant")

      expect(merchant).to have_key(:attributes)
      expect(merchant[:attributes]).to be_a(Hash)

      expect(merchant[:attributes]).to have_key(:name)
      expect(merchant[:attributes][:name]).to be_a(String)
    end
  end

  it 'returns the total revenue across all merchants between the given dates' do
    total_revenue = @m1_tr + @m2_tr + @m4_tr + @m6_tr

    get "/api/v1/revenue?start=#{@inv1.created_at}&end=#{@inv1.created_at}"

    revenue = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful

    expect(revenue[:data]).to be_a(Hash)

    expect(revenue[:data][:id]).to be_nil
    expect(revenue[:data][:attributes]).to be_a(Hash)
    expect(revenue[:data][:attributes][:revenue]).to eq(total_revenue)
  end

  it 'returns the total revenue for a single merchant' do
    get "/api/v1/merchants/#{@m1.id}/revenue"

    revenue = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful

    expect(revenue[:data]).to be_a(Hash)

    expect(revenue[:data][:id]).to be_nil
    expect(revenue[:data][:attributes]).to be_a(Hash)
    expect(revenue[:data][:attributes][:revenue]).to eq(@m1_tr)
  end

  it 'returns maximum number of merchants that meet conditions ranked by total number of items sold if variable number given exceeds total of unique records' do
    get '/api/v1/merchants/most_items?quantity=7'

    merchants = JSON.parse(response.body, symbolize_names: true)
    
    expect(response).to be_successful

    expect(merchants[:data]).to be_an(Array)
    expect(merchants[:data].count).to eq(4)

    expect(merchants[:data].first[:id]).to eq(@m1.id.to_s)
    expect(merchants[:data].second[:id]).to eq(@m4.id.to_s)
    expect(merchants[:data].third[:id]).to eq(@m6.id.to_s)
    expect(merchants[:data].fourth[:id]).to eq(@m2.id.to_s)

    merchants[:data].each do |merchant|
      expect(merchant).to have_key(:type)
      expect(merchant[:type]).to eq("merchant")

      expect(merchant).to have_key(:attributes)
      expect(merchant[:attributes]).to be_a(Hash)

      expect(merchant[:attributes]).to have_key(:name)
      expect(merchant[:attributes][:name]).to be_a(String)
    end
  end

  it 'returns nil value for revenue key if merchant id does not exist' do
    get "/api/v1/merchants/#{Faker::Number.number(digits: 10)}/revenue"

    revenue = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful

    expect(revenue[:data]).to be_a(Hash)

    expect(revenue[:data][:id]).to be_nil
    expect(revenue[:data][:attributes]).to be_a(Hash)
    expect(revenue[:data][:attributes][:revenue]).to be_nil
  end
end
