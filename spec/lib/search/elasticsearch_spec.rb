require 'spec_helper'
describe Spree::Search::Elasticsearch do
  before do
    @product1 = create(:product, :name => "Nike Golf women's Lunar Golf Shoe", :price => 80.00)
    @product2 = create(:product, :name => "Nike Golf men's Lunar Golf Shoe", :price => 85.00)
    Spree::Product.__elasticsearch__.client.indices.refresh
  end

  context "#search" do
    it "should find the women's shoe" do
      searcher = Spree::Search::Elasticsearch.new(:keywords => "women's", :per_page => "")
      response = searcher.retrieve_products
    end
  end
end
