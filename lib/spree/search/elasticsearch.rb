module Spree
  module Search
    class Elasticsearch < Spree::Core::Search::Base
      def initialize(params)
        self.current_currency = Spree::Config[:currency]
        @properties = {}
        prepare(params)
        prepare_extra_params(params)
      end

      def retrieve_products
        @products_scope = get_base_scope
        curr_page = page || 1

        if keywords.present?
          @products = @products_scope.page(curr_page).per(per_page).records
        else
          @products = @products_scope.includes(master: [:prices, :images])
          unless Spree::Config.show_products_without_price
            @products = @products.where("spree_prices.amount IS NOT NULL").where("spree_prices.currency" => Spree::Config[:presentation_currency] || current_currency)
          end

          case sort_type
          when "newest"
            @products = @products.descend_by_created_at
          when "price_asc"
            @products = @products.order("spree_prices ASC")
            #sort_by{|obj| obj.variants.any? ? obj.variants.first.price : obj.price}
          when "price_desc"
            @products = @products.order("spree_prices DESC")
            #@products = @products.sort_by{|obj| obj.variants.any? ? obj.variants.first.price : obj.price}.reverse
          end

          if no_pagination
            @products
          else
            @products = sort_type.present? ? Kaminari.paginate_array(@products).page(curr_page).per(per_page) : @products.page(curr_page).per(per_page)
          end
        end
        @products
      end

      protected
      def get_base_scope
        if keywords.nil?
          base_scope = Spree::Product.active
          base_scope = base_scope.in_taxon(taxon) unless taxon.blank?
          base_scope = add_search_scopes(base_scope)
          # filter out products without images
          base_scope = base_scope.has_images
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

      def prepare_extra_params(params)
        @properties[:sort_type] = params[:sort_type].present? ? params[:sort_type] : ""
        @properties[:no_pagination] = params[:no_pagination].present? ? params[:no_pagination] : false
      end
    end
  end
end
