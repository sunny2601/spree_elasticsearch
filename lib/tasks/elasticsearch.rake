config_file = ::Rails.root.join('config/elasticsearch.yml')
index_config = ::Rails.root.join('config/index.yml')
mapping_config = ::Rails.root.join('config/mapping.yml')

if config_file.file?
  config = YAML.load(ERB.new(config_file.read).result)
  config = if config then config else nil end
end

if index_config.file?
  index_body = YAML.load(ERB.new(index_config.read).result)
  index_body = if index_body then index_body else nil end
end

if mapping_config.file?
  mappings = YAML.load(ERB.new(mapping_config.read).result)
  mappings = if mappings then mappings else nil end
end


namespace :elasticsearch do
  task :refresh_index => :environment do
    INDEX = "#{ENV['RAILS_ENV'] || "development"}_#{Spree::Config.site_name.downcase.gsub " ","_"}"
    begin
    Spree::Product.__elasticsearch__.client.indices.delete index: INDEX
    Spree::Product.__elasticsearch__.client.indices.create index: INDEX, body: index_body
    rescue Elasticsearch::Transport::Transport::Errors::BadRequest
    end

    if !mappings.nil?
      mappings.each do |mapping|
        begin
          Elasticsearch::Model.client.indices.put_mapping index: INDEX, type: mapping["type"], body: mapping["mapping"]
        rescue Elasticsearch::Transport::Transport::Errors::BadRequest
        end
      end
    end
    Spree::Product.where(out_of_date_at: nil).find_each do |product|
      product.save
    end
  end
end
