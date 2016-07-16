ActiveAdmin.register Payout do
	permit_params :user_id, :value
	config.filters = false
	config.batch_actions = false
	actions :all, except: :show

	index do
		column(:id)
		column(:created_at)
		column(:user)
		column(:value)
		actions
	end

	form do |f|
		f.inputs 'Payout' do
			f.input :user
			f.input :value
			f.actions
		end
	end
end
