class Payment < ActiveRecord::Base
  belongs_to :payable, polymorphic: true

  def pending?
    status == 'pending'
  end
end
