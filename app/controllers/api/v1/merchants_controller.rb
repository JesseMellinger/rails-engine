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
    attribute = merchant_params.keys.first
    value = merchant_params.values.first.to_s
    merchant = Merchant.find_by_attribute(attribute, value)
    render json: MerchantSerializer.new(merchant)
  end

  def find_all
    attribute = merchant_params.keys.first
    value = merchant_params.values.first.to_s
    merchants = Merchant.find_all_by_attribute(attribute, value)
    render json: MerchantSerializer.new(merchants)
  end

  def most_revenue
    merchants = Merchant.most_revenue(params[:quantity])
    render json: MerchantSerializer.new(merchants)
  end

  def most_items
    merchants = Merchant.most_items(params[:quantity].to_i)
    render json: MerchantSerializer.new(merchants)
  end

  def revenue_between_dates
    revenue = FindRevenueFacade.find_revenue_by_dates(params[:start], params[:end])
    render json: RevenueSerializer.new(revenue.first)
  end

  def revenue
    revenue = FindRevenueFacade.find_revenue_of_merchant(params[:id])
    render json: RevenueSerializer.new(revenue.first)
  end

  private
  def merchant_params
    params.permit(:name, :created_at, :updated_at)
  end
end
