class VerifyArtistSimple
	include Grape::DSL::InsideRoute

  def call
		status 422 unless update_user && update_address
  end

  private

  attr_accessor :user, :params

  def initialize(user, params)
    @user = user
    @params = params
  end

  def update_address
    params.has_company ? CompanyAddress.new(user, params).call : true
  end

  def update_user
    user_params = { artist: true, handle: params.handle }
    user.update(user_params)
  end
end
