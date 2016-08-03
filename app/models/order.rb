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

  scope :list_all, -> { where('order_status != 0') }
  scope :waiting_products, ->(order) { order.products.where(design_id: nil) }
  scope :processing, -> { where(order_status: 2) }
  scope :creating, -> { where(order_status: 0) }
  scope :payment_pending, -> { where(order_status: 1) }
  scope :completed, -> { where(order_status: 4) }
  scope :failed, -> { where(order_status: 5) }
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
