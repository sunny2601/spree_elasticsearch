require 'spec_helper'
describe Spree::Search::Elasticsearch do
  before do
    @product1 = create(:product, :name => "Nike Golf women's Lunar Golf Shoe", :price => 80.00)
    @product2 = create(:product, :name => "Nike Golf men's Lunar Golf Shoe", :price => 85.00)
    @product3 = create(:product, :name => "BOSS Black by Hugo Boss Men's Cauro Oxford", :price => 166.32)
    @product4 = create(:product, :name => "BOSS Orange by Hugo Boss Men's Ofero Wingtip", :price => 215257)
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
      expect(response.to_a.length).to eql(3)
      expect(response.to_a.first.name).to eql(@product3.name)
    end

    it "should find the mens and womens shoes, but the womens shoe should be first" do
      search = Spree::Search::Elasticsearch.new(:keywords => "women's golf shoe", :per_page => "")
      response = search.retrieve_products
      expect(response.to_a.length).to eql(2)
      expect(response.to_a.first.name).to eql(@product1.name)
    end

    it "should find the mens and womens shoes, but the mens shoe should be first" do
      search = Spree::Search::Elasticsearch.new(:keywords => "men's nike golf shoe", :per_page => "")
      response = search.retrieve_products
      expect(response.to_a.length).to eql(4)
      expect(response.to_a.first.name).to eql(@product2.name)
    end

    it "should return page one of two pages of results" do
      search = Spree::Search::Elasticsearch.new(:keywords => "mens", :per_page => "2")
      response = search.retrieve_products
      expect(response.to_a.length).to eql(2)
      expect(response.to_a.first).to eql(@product3)
      expect(response.to_a.last).to eql(@product4)
    end

    it "should return page two of two pages of results" do
      search = Spree::Search::Elasticsearch.new(:keywords => "mens", :per_page => "2", :page => "2")
      response = search.retrieve_products
      expect(response.to_a.length).to eql(1)
      expect(response.to_a.first).to eql(@product2)
    end

    it "should match the synonym" do
      search = Spree::Search::Elasticsearch.new(:keywords => "신발", :per_page => "")
      response = search.retrieve_products
      expect(response.to_a.length).to eql(2)
      expect(response.to_a.first).to eql(@product1)
    end

    it "should match the multiple synonym search" do
      search = Spree::Search::Elasticsearch.new(:keywords => "남자 신발", :per_page => "")
      response = search.retrieve_products
      expect(response.to_a.length).to eql(4)
    end

  end
end
