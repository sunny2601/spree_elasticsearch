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
        end
        if keywords.nil?
          @products = @products.sort_by{|obj| obj.created_at}.reverse if sort_type == "newest"
          @products = @products.sort_by{|obj| obj.variants.any? ? obj.variants.first.price : obj.price} if sort_type == "price_asc"
          @products = @products.sort_by{|obj| obj.variants.any? ? obj.variants.first.price : obj.price}.reverse if sort_type == "price_desc"
          if no_pagination
            @products
          else
            @products = sort_type.present? ? Kaminari.paginate_array(@products).page(curr_page).per(per_page) : @products.page(curr_page).per(per_page)
          end
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
             # only apply brand filter if this taxon has products with that brand
             base_scope = add_search_scopes(base_scope) unless add_search_scopes(base_scope).empty?
             base_scope = base_scope.has_images
             #base_scope = base_scope.descend_by_created_at
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

        def prepare(params)
          @properties[:taxon] = params[:taxon].blank? ? nil : Spree::Taxon.find(params[:taxon])
          @properties[:keywords] = params[:keywords]
          @properties[:search] = params[:search]

          per_page = params[:per_page].to_i
          @properties[:per_page] = per_page > 0 ? per_page : Spree::Config[:products_per_page]
          @properties[:page] = (params[:page].to_i <= 0) ? 1 : params[:page].to_i
          @properties[:sort_type] = params[:sort_type].present? ? params[:sort_type] : ""
          @properties[:no_pagination] = params[:no_pagination].present? ? params[:no_pagination] : false
        end

    end
  end
end
