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

          @products = @products.select("spree_prices.amount, spree_products.*").distinct

          case sort_type
          when "newest"
            @products = @products.descend_by_created_at
          when "price_asc"
            @products = @products.ascend_by_master_price
            #.order("spree_prices.amount ASC")
          when "price_desc"
            @products = @products.descend_by_master_price
            #.order("spree_prices.amount DESC")
          end

          unless no_pagination
            @products = sort_type.present? ? Kaminari.paginate_array(@products).page(curr_page).per(per_page) : @products.page(curr_page).per(per_page)
          end
        end
        @products
      end

      protected
      def get_base_scope
        if keywords.nil?
          base_scope = Spree::Product.active
          unless taxon.blank?
            # `in_taxon` sorts by admin taxon order; `in_taxons` doesn't
            if sort_type.present? and sort_type != "recommended"
              base_scope = base_scope.in_taxons(taxon)
            else
              base_scope.in_taxon(taxon)
            end
          end
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
