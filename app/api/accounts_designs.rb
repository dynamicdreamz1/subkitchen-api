module AccountsDesigns
  class Api < Grape::API

    resource :account do
      resource :designs do

        desc 'user designs'
        params do
          optional :page, type: Integer, default: 1
          optional :per_page, type: Integer, default: 30
        end
        get do
          authenticate!
          designed_products = current_user.products.page(params.page).per(params.per_page)
          UserDesignsSerializer.new(designed_products).as_json
        end
      end
    end
  end
end