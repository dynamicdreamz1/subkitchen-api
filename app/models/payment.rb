class Payment < ActiveRecord::Base
  belongs_to :payable, polymorphic: true
  scope :completed, -> { where(payment_status: 'completed') }
  scope :denied, -> { where(payment_status: 'denied') }
  scope :malformed, -> { where(payment_status: 'malformed') }
  scope :pending, -> { where(payment_status: 'pending') }
end
