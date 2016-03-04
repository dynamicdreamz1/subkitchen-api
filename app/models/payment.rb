class Payment < ActiveRecord::Base
  belongs_to :payable, polymorphic: true

  def pending?
    payment_status == 'pending'
  end
end
