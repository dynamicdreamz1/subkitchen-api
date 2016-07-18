module AccountsPayouts
  class Api < Grape::API
    resource :payouts do
			desc 'list all payouts of user'
			params do
				optional :page, type: Integer, default: 1
				optional :per_page, type: Integer, default: 15
			end
			get do
				authenticate!
				payout = Payout.user(current_user.id)
					.order('created_at DESC')
					.page(params.page)
					.per(params.per_page)
				PayoutListSerializer.new(payout).as_json
			end
    end
  end
end
