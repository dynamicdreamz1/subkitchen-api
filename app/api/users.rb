module Users
  class Api < Grape::API
    resources :users do
      desc 'return user by id'
      get ':id' do
        {user: UserPublicSerializer.new(User.find(params[:id])) }
      end
    end
  end
end
