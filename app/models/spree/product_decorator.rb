Spree::Product.class_eval do
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  index_name "#{ENV['RAILS_ENV'] || "development"}_#{Spree::Config.site_name.downcase.gsub " ","_"}"
  document_type 'product'

  add_simple_scopes [:descend_by_created_at]
  add_search_scope :has_images do
    joins(master: :images)
  end

  add_search_scope :brand do |brand|
    brand = brand.split(',')
    where("data -> 'brand' IN (?)", brand)
  end
  add_search_scope :merchant do |merchant|
    where("data -> 'merchant' = ?", merchant)
  end

  def self.es_search(query)
    response = self.__elasticsearch__.search query
    response
  end
  def as_indexed_json(options={})
    if !self.images.empty?
      image_url = self.images.first.attachment.url
    end
    taxons = self.taxons.map { |t| t.name }
    product = {
      name: self.name,
      taxons: taxons,
      price: self.price,
      image_url: image_url
    }
    product.to_json
  end

  after_commit on: [:create] do
    index_document
  end

  after_commit on: [:update] do
    update_document
  end

  after_commit on: [:destroy] do
    delete_document
  end

  #this can be modified to call a background worker
  def index_document
    __elasticsearch__.index_document
  end

  def delete_document
    __elasticsearch__.delete_document
  end

  #alias this method so that an update completely overwrites the document and
  #doesn't update only the updated fields
  alias_method :update_document,:index_document

end
