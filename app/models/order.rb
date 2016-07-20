class Order < ActiveRecord::Base
  belongs_to :user
  has_many :order_items
  has_one :payment, as: :payable
  has_many :products, through: :order_items
  has_one :invoice
  belongs_to :coupon

  after_create SetTaxAndShipping.new
  after_save SalesCountCallback.new, if: :purchased_changed?

  enum order_status: { creating: 0, payment_pending: 1, processing: 2, cooking: 3, completed: 4, failed: 5 }

  validates_with AddressValidator, on: :update

  scope :waiting_products, ->(order) { order.products.where(design_id: nil) }
  scope :processing, -> { where(order_status: 'processing') }
  scope :creating, -> { where(order_status: 'creating') }
  scope :payment_pending, -> { where(order_status: 'payment_pending') }
	scope :completed, -> { where(order_status: 'completed' ) }
	scope :failed, -> { where(order_status: 'failed') }
  scope :user, -> (user_id) { where(user_id: user_id) }

  validates :full_name, presence: true, on: :address
  validates :city,      presence: true, on: :address
  validates :address,   presence: true, on: :address
  validates :zip,       presence: true, on: :address
  validates :region,    presence: true, on: :address
  validates :country,   presence: true, on: :address
  validates :email,     presence: true, email: true, on: :address

	def record_number
		"#{id}/#{created_at.strftime('%d/%m/%Y')}"
	end
end
