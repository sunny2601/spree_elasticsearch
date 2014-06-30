module Spree
  module Search
    class Elasticsearch < Spree::Core::Search::Base
       protected
         def get_base_scope
           if keywords.nil?
             base_scope = Spree::Product.active
             base_scope = base_scope.in_taxon(taxon) unless taxon.blank?
             base_scope = add_search_scopes(base_scope)
             base_scope
           else
             elasticsearch_query = build_es_query(keywords)
             base_scope = Spree::Product.es_search(elasticsearch_query)
             base_scope
           end
         end

         def build_es_query(keywords)
           query = {
             "query" => {
               "query_string" => {
                 "default_field" => "name",
                 "query" => keywords
               }
             }
           }
           query
         end
    end
  end
end
