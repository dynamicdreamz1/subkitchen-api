class Payment < ActiveRecord::Base
  belongs_to :payable, polymorphic: true
  scope :completed, -> { where(payment_status: 1) }
  scope :denied, -> { where(payment_status: 0) }
  scope :malformed, -> { where(payment_status: 3) }
  scope :pending, -> { where(payment_status: 2) }

  enum payment_status: { denied: 0, completed: 1, pending: 2, malformed: 3 }

  validates :payable_id, presence: true
  validates :payable_type, presence: true
  validates :payment_type, presence: true, inclusion: { in: %w(stripe paypal) }
end
