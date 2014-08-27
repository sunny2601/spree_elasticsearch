module Spree
  module Search
    class Elasticsearch < Spree::Core::Search::Base
      def retrieve_products
        @products_scope = get_base_scope
        curr_page = page || 1

        if keywords.nil?
          @products = @products_scope.includes([:master => :prices])
        end
        if !@products.nil?
          unless Spree::Config.show_products_without_price
            @products = @products.where("spree_prices.amount IS NOT NULL").where("spree_prices.currency" => Spree::Config[:presentation_currency] || current_currency)
          end
          @products = @products.select { |product| product.images.length > 0 }
        end
        if keywords.nil?
          @products = @products.page(curr_page).per(per_page)
        else
          @products = @products_scope.page(curr_page).per(per_page).records
        end
        @products
      end

       protected
         def get_base_scope
           if keywords.nil?
             base_scope = Spree::Product.active
             base_scope = base_scope.in_taxon(taxon) unless taxon.blank?
             base_scope = add_search_scopes(base_scope)
             base_scope = base_scope.descend_by_created_at
             base_scope
           else
             elasticsearch_query = build_es_query
             base_scope = Spree::Product.es_search(elasticsearch_query)
             base_scope
           end
         end

         def build_es_query
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
