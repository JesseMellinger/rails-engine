require 'rails_helper'

describe "Merchants API" do
  it "sends a list of all merchants" do
    create_list(:merchant, 3)

    get '/api/v1/merchants'

    expect(response).to be_successful

    merchants = JSON.parse(response.body, symbolize_names: true)

    expect(merchants[:data].count).to eq(3)

    merchants[:data].each do |merchant|
      expect(merchant).to have_key(:id)
      expect(merchant[:id]).to be_an(String)

      expect(merchant).to have_key(:type)
      expect(merchant[:type]).to eq("merchant")

      expect(merchant).to have_key(:attributes)
      expect(merchant[:attributes]).to be_a(Hash)

      expect(merchant[:attributes]).to have_key(:name)
      expect(merchant[:attributes][:name]).to be_a(String)
    end
  end

  it "can get one merchant by its id" do
    id = create(:merchant).id

    get "/api/v1/merchants/#{id}"

    merchant = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful

    expect(merchant[:data]).to have_key(:id)
    expect(merchant[:data][:id]).to eq(id.to_s)

    expect(merchant[:data]).to have_key(:type)
    expect(merchant[:data][:type]).to eq("merchant")

    expect(merchant[:data]).to have_key(:attributes)
    expect(merchant[:data][:attributes]).to be_a(Hash)

    expect(merchant[:data][:attributes]).to have_key(:name)
    expect(merchant[:data][:attributes][:name]).to be_a(String)
  end

  it "can create a new merchant" do
    merchant_params = ({
                        name: Faker::Company.name
                      })
    headers = {"CONTENT_TYPE" => "application/json"}

    post "/api/v1/merchants", headers: headers, params: JSON.generate(merchant_params)

    created_merchant = Merchant.last

    expect(response).to be_successful
    expect(created_merchant.name).to eq(merchant_params[:name])
  end

  it "can update an existing merchant" do
    id = create(:merchant).id
    previous_name = Merchant.last.name

    merchant_params = { name: Faker::Company.name }
    headers = {"CONTENT_TYPE" => "application/json"}

    patch "/api/v1/merchants/#{id}", headers: headers, params: JSON.generate(merchant_params)

    merchant = Merchant.find_by(id: id)

    expect(response).to be_successful
    expect(merchant.name).to_not eq(previous_name)
    expect(merchant.name).to eq(merchant_params[:name])
  end

  it "can destroy a merchant" do
    merchant = create(:merchant)

    expect{ delete "/api/v1/merchants/#{merchant.id}" }.to change(Merchant, :count).by(-1)

    expect(response).to be_successful
    expect{Merchant.find(merchant.id)}.to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'returns the merchant associated with an item' do
    merchant = create(:merchant)
    item = create(:item, merchant: merchant)

    get "/api/v1/items/#{item.id}/merchants"

    merchant_response = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful

    expect(merchant_response[:data]).to be_a(Hash)

    expect(merchant_response[:data]).to have_key(:id)
    expect(merchant_response[:data][:id]).to be_an(String)

    expect(merchant_response[:data]).to have_key(:type)
    expect(merchant_response[:data][:type]).to eq("merchant")

    expect(merchant_response[:data]).to have_key(:attributes)
    expect(merchant_response[:data][:attributes]).to be_a(Hash)

    expect(merchant_response[:data][:attributes]).to have_key(:name)
    expect(merchant_response[:data][:attributes][:name]).to eq(merchant.name)
  end

  it 'finds a single record that matches a set of criteria with partial strings and case insensitivity' do
    merchants = create_list(:merchant, 3)

    get "/api/v1/merchants/find?name=#{merchants.second.name}"

    merchant = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful

    expect(merchant[:data]).to be_a(Hash)

    expect(merchant[:data]).to have_key(:id)
    expect(merchant[:data][:id]).to eq(merchants.second.id.to_s)

    expect(merchant[:data]).to have_key(:type)
    expect(merchant[:data][:type]).to eq("merchant")

    expect(merchant[:data]).to have_key(:attributes)
    expect(merchant[:data][:attributes]).to be_a(Hash)

    expect(merchant[:data][:attributes]).to have_key(:name)
    expect(merchant[:data][:attributes][:name]).to eq(merchants.second.name)

    merchants.second.update!(name: "Turing")
    merchants.third.update!(name: "Ring World")

    get "/api/v1/merchants/find?name=Ing"

    merchant = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful

    expect(merchant[:data]).to be_a(Hash)

    expect(merchant[:data]).to have_key(:id)
    expect(merchant[:data][:id]).to eq(merchants.second.id.to_s)

    expect(merchant[:data]).to have_key(:type)
    expect(merchant[:data][:type]).to eq("merchant")

    expect(merchant[:data]).to have_key(:attributes)
    expect(merchant[:data][:attributes]).to be_a(Hash)

    expect(merchant[:data][:attributes]).to have_key(:name)
    expect(merchant[:data][:attributes][:name]).to eq(merchants.second.name)
  end

  it 'finds a single record by timestamps' do
    merchants = create_list(:merchant, 3)

    get "/api/v1/merchants/find?created_at=#{merchants.second.created_at}"

    merchant = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful

    expect(merchant[:data]).to be_a(Hash)

    expect(merchant[:data]).to have_key(:id)
    expect(merchant[:data][:id]).to eq(merchants.first.id.to_s)

    expect(merchant[:data]).to have_key(:type)
    expect(merchant[:data][:type]).to eq("merchant")

    expect(merchant[:data]).to have_key(:attributes)
    expect(merchant[:data][:attributes]).to be_a(Hash)

    expect(merchant[:data][:attributes]).to have_key(:name)
    expect(merchant[:data][:attributes][:name]).to eq(merchants.first.name)

    merchants.first.update!(updated_at: 10.days.from_now)

    get "/api/v1/merchants/find?updated_at=#{merchants.second.updated_at}"

    merchant = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful

    expect(merchant[:data]).to be_a(Hash)

    expect(merchant[:data]).to have_key(:id)
    expect(merchant[:data][:id]).to eq(merchants.second.id.to_s)

    expect(merchant[:data]).to have_key(:type)
    expect(merchant[:data][:type]).to eq("merchant")

    expect(merchant[:data]).to have_key(:attributes)
    expect(merchant[:data][:attributes]).to be_a(Hash)

    expect(merchant[:data][:attributes]).to have_key(:name)
    expect(merchant[:data][:attributes][:name]).to eq(merchants.second.name)
  end

  it 'finds all records that match a set of criteria with partial strings and case insensitivity' do
    merchants = create_list(:merchant, 3)

    merchants.first.update!(name: "Ring World")
    merchants.second.update!(name: "Treutel-Toy")
    merchants.third.update!(name: "Turing School")

    get "/api/v1/merchants/find_all?name=RiNg"

    merchant_response = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful

    expect(merchant_response[:data]).to be_an(Array)
    expect(merchant_response[:data].count).to eq(2)

    expect(merchant_response[:data]).to include(a_hash_including(:id => merchants.first.id.to_s))
    expect(merchant_response[:data]).to include(a_hash_including(:id => merchants.third.id.to_s))

    merchant_response[:data].each do |merchant|
      expect(merchant).to have_key(:type)
      expect(merchant[:type]).to eq("merchant")

      expect(merchant).to have_key(:attributes)
      expect(merchant[:attributes]).to be_a(Hash)

      expect(merchant).to have_key(:attributes)
      expect(merchant[:attributes][:name]).to be_a(String)
    end
  end

  it 'finds all records by timestamps' do
    merchants = create_list(:merchant, 3)

    get "/api/v1/merchants/find_all?created_at=#{merchants.second.created_at}"

    merchant_response = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful

    expect(merchant_response[:data]).to be_an(Array)
    expect(merchant_response[:data].count).to eq(3)

    expect(merchant_response[:data].first[:id]).to eq(merchants.first.id.to_s)
    expect(merchant_response[:data].second[:id]).to eq(merchants.second.id.to_s)
    expect(merchant_response[:data].third[:id]).to eq(merchants.third.id.to_s)

    merchant_response[:data].each do |merchant|
      expect(merchant).to have_key(:type)
      expect(merchant[:type]).to eq("merchant")

      expect(merchant).to have_key(:attributes)
      expect(merchant[:attributes]).to be_a(Hash)

      expect(merchant[:attributes]).to have_key(:name)
      expect(merchant[:attributes][:name]).to be_a(String)
    end

    merchants.first.update!(updated_at: 10.days.from_now)

    get "/api/v1/merchants/find_all?updated_at=#{merchants.second.updated_at}"

    merchant_response = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful

    expect(merchant_response[:data]).to be_a(Array)
    expect(merchant_response[:data].count).to eq(2)

    expect(merchant_response[:data].first[:id]).to eq(merchants.second.id.to_s)
    expect(merchant_response[:data].last[:id]).to eq(merchants.third.id.to_s)

    merchant_response[:data].each do |merchant|
      expect(merchant).to have_key(:type)
      expect(merchant[:type]).to eq("merchant")

      expect(merchant).to have_key(:attributes)
      expect(merchant[:attributes]).to be_a(Hash)

      expect(merchant[:attributes]).to have_key(:name)
      expect(merchant[:attributes][:name]).to be_a(String)
    end
  end
end
