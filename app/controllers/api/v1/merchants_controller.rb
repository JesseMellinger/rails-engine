class Api::V1::MerchantsController < ApplicationController
  def index
    render json: MerchantSerializer.new(Merchant.all)
  end

  def show
    render json: MerchantSerializer.new(Merchant.find(params[:id]))
  end

  def create
    render json: MerchantSerializer.new(Merchant.create(merchant_params))
  end

  def update
    render json: MerchantSerializer.new(Merchant.update(params[:id], merchant_params))
  end

  def destroy
    Merchant.destroy(params[:id])
    render body: nil, status: 204
  end

  def find
    key = merchant_params.keys.first
    value = merchant_params.values.first.to_s
    merchant = Merchant.find_by_attribute(key, value)
    render json: MerchantSerializer.new(merchant)
  end

  def find_all
    key = merchant_params.keys.first
    value = merchant_params.values.first.to_s
    merchants = Merchant.find_all_by_attribute(key, value)
    render json: MerchantSerializer.new(merchants)
  end

  private
  def merchant_params
    params.permit(:name, :created_at, :updated_at)
  end
end
