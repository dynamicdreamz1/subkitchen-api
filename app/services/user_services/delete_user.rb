class DeleteUser
  def call
    delete_user
  end

  private

  def initialize(user)
    @user = user
  end

  def delete_user
    @user.update_columns(
      is_deleted: true,
      email: '',
      status: '',
      provider: '',
      uid: '',
      first_name: '',
      last_name: '',
      address: '',
      city: '',
      zip: '',
      region: '',
      phone: '',
			location: '',
			website: '',
			paypal_id: '',
			bio: '',
			featured: false,
      profile_image: '',
      shop_banner: ''
    )
  end
end
