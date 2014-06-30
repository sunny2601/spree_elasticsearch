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
      expect(response.to_a.length).to eql(1)
      expect(response.to_a.first.name).to eql(@product1.name)
    end

    it "should find the mens shoe" do
      search = Spree::Search::Elasticsearch.new(:keywords => "men's", :per_page => "")
      response = search.retrieve_products
      expect(response.to_a.length).to eql(1)
      expect(response.to_a.first.name).to eql(@product2.name)
    end

    it "should find the mens and womens shoes, but the womens shoe should be first" do
      search = Spree::Search::Elasticsearch.new(:keywords => "women's golf shoe", :per_page => "")
      response = search.retrieve_products
      expect(response.to_a.length).to eql(2)
      expect(response.to_a.first.name).to eql(@product1.name)
    end

    it "should find the mens and womens shoes, but the mens shoe should be first" do
      search = Spree::Search::Elasticsearch.new(:keywords => "men's golf shoe", :per_page => "")
      response = search.retrieve_products
      expect(response.to_a.length).to eql(2)
      expect(response.to_a.first.name).to eql(@product2.name)
    end
  end
end
