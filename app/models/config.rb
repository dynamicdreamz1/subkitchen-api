class Config < ActiveRecord::Base
  scope :shipping_info, lambda {
    where(name: 'shipping_info')
  }
  scope :shipping_cost, lambda {
    where(name: 'shipping_cost')
  }
  scope :tax, lambda {
    where(name: 'tax')
  }
end
