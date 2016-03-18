class Order < ActiveRecord::Base
  belongs_to :user
  has_many :order_items
  has_one :payment, as: :payable

  after_create SetTaxAndShipping.new

  validates_with AddressValidator, on: :update

  scope :completed, -> { where(purchased: true) }
end