class Api::V1::ItemsController < ApplicationController
  def index
    render json: ItemSerializer.new(Item.all)
  end

  def show
    render json: ItemSerializer.new(Item.find(params[:id]))
  end

  def create
    render json: ItemSerializer.new(Item.create(item_params))
  end

  def update
    render json: ItemSerializer.new(Item.update(params[:id], item_params))
  end

  def destroy
    Item.destroy(params[:id])
    render body: nil, status: 204
  end

  def find
    attribute = item_params.keys.first
    value = item_params.values.first.to_s
    if ActiveRecord::Base.connection.column_exists?(:items, attribute)
      item = Item.find_by_attribute(attribute, value)
      render json: ItemSerializer.new(item)
    else
      payload = {
        error: "No such attribute for items",
        status: 400
      }
      render :json => payload, :status => :bad_request
    end
  end

  def find_all
    attribute = item_params.keys.first
    value = item_params.values.first.to_s
    items = Item.find_all_by_attribute(attribute, value)
    render json: ItemSerializer.new(items)
  end

  private
  def item_params
    params.permit(:name, :description, :unit_price, :merchant_id, :created_at, :updated_at)
  end
end
