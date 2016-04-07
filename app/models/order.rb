class Order < ActiveRecord::Base
  belongs_to :user
  has_many :order_items
  has_one :payment, as: :payable
  has_many :products, through: :order_items
  has_one :invoice

  after_create SetTaxAndShipping.new

  validates_with AddressValidator, on: :update

  scope :completed, -> { where(purchased: true) }
  scope :waiting_products, ->(order) { order.products.where(design_id: nil) }
  scope :processing, -> { where(order_status: 'processing') }

  validates :full_name, presence: true, on: :address
  validates :city,      presence: true, on: :address
  validates :address,   presence: true, on: :address
  validates :zip,       presence: true, on: :address
  validates :region,    presence: true, on: :address
  validates :country,   presence: true, on: :address
  validates :email,     presence: true, email: true, on: :address
end
