class Company < ActiveRecord::Base
  belongs_to :user
  validate :user_artist

  def user_artist
   unless user.artist
     errors.add(:user_id, "must be an artist ")
   end
  end
end
