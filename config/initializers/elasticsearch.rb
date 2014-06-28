require 'elasticsearch/model'

config_file = ::Rails.root.join('config/elasticsearch.yml')

if config_file.file?
  config = YAML.load(ERB.new(config_file.read).result)
  config = if config then config else nil end
end

Elasticsearch::Model.client = if config.nil? then Elasticsearch::Client.new else Elasticsearch::Client.new config end
begin
  Elasticsearch::Model.client.indices.create index: "#{ENV['RAILS_ENV'] || "development"}_#{Spree::Config.site_name.downcase.gsub " ","_"}"
rescue
  puts "Index exists skipping creation"
end

Elasticsearch::Model.client.indices.put_mapping type: 'product', body: {
  product: {
    properties: {
      name: {
        type: 'multi_field',
        fields: {
          name: { type: 'string', analyzer: 'english', index_options: 'offsets' },
          na_name: { type: 'string', index: 'not_analyzed' }
        }
      },
      taxons: {
        type: 'string',
        index: 'not_analyzed'
      }
    }
  }
}
