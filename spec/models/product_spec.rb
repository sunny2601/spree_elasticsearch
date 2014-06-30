require 'spec_helper'

describe Spree::Product do
  before do
    @index = "#{ENV['RAILS_ENV'] || "development"}_#{Spree::Config.site_name.downcase.gsub " ","_"}"
    @shipping_category = Spree::ShippingCategory.create!(name: 'default')
    @product = Spree::Product.create!(id: 1, name: 'Test', price: 20.00, shipping_category_id: @shipping_category.id)
    Spree::Product.__elasticsearch__.client.indices.refresh
  end

  it 'should have indexed a product in elasticsearch' do
    response = Spree::Product.__elasticsearch__.client.get index: @index,type: 'product', id: @product.id
    expected = {
      "_id" => "1",
      "_index" => "test_spree_demo_site",
      "_source" => {
        "name" => "Test", "taxons" => [], "price"=> "20.0", "image_url"=> nil
      },
      "_type" => "product",
      "_version" => 2,
      "found" => true
    }
    expect(response).to eq(expected)
  end
end
