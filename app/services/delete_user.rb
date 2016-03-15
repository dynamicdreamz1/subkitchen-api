class DeleteUser
  def call
    delete_user
  end

  private

  def initialize(user)
    @user = user
  end

  def delete_user
    @user.update(
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
             profile_image_id: '',
             shop_banner_id: ''
    )
  end
end