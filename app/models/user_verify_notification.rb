class UserVerifyNotification < ActiveRecord::Base
  belongs_to :order
  serialize :params
  after_create :mark_user_as_artist

  private

  def mark_user_as_artist
    if status == 'Completed'
      order.user.update_attribute(:status, 'verified')
      order.update_attributes(purchased_at: DateTime.now, state: :inactive)
    end
  end
end
