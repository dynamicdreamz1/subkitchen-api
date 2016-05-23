class Order < ActiveRecord::Base
  belongs_to :user
  has_many :order_items
  has_one :payment, as: :payable
  has_many :products, through: :order_items
  has_one :invoice
  belongs_to :coupon

  after_create SetTaxAndShipping.new

  enum order_status: { creating: 0, 'payment pending': 1, processing: 2, cooking: 3, completed: 4 }

  validates_with AddressValidator, on: :update

  scope :completed, -> { where(purchased: true) }
  scope :waiting_products, ->(order) { order.products.where(design_id: nil) }
  scope :processing, -> { where(order_status: 'processing') }
  scope :user, -> (user_id) { where(user_id: user_id) }


  validates :full_name, presence: true, on: :address
  validates :city,      presence: true, on: :address
  validates :address,   presence: true, on: :address
  validates :zip,       presence: true, on: :address
  validates :region,    presence: true, on: :address
  validates :country,   presence: true, on: :address
  validates :email,     presence: true, email: true, on: :address
end
