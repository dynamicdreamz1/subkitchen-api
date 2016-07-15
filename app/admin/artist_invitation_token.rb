ActiveAdmin.register ArtistInvitationToken do
	config.filters = false
	config.batch_actions = false
	actions :index

	action_item :generate do
		link_to 'Generate Tokens', generate_tokens_form_admin_artist_invitation_tokens_path, method: :get
	end

	collection_action :generate_tokens_form, method: :get do
		@token = ArtistInvitationToken.new
		def @token.amount; end
	end

	collection_action :generate_tokens, method: :post do
		params['artist_invitation_token']['amount'].to_i.times do
			ArtistInvitationToken.create!
		end
		redirect_to admin_artist_invitation_tokens_path,
								notice: "Created #{params['artist_invitation_token']['amount']} tokens!"
	end

	index do
		selectable_column
		column(:uuid)
		column 'Url' do |token|
			Figaro.env.frontend_host + "/become-cook?uuid=#{token.uuid}"
		end
		column(:user)
		actions
	end
end
