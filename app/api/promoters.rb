module Promoters
  class Api < Grape::API
    resource :promoters do
      desc 'get promoter'
      get '/:id' do
        PromoterSerializer.new(User.find(params.id))
      end
    end
  end
end
