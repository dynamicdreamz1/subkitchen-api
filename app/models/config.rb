class Config < ActiveRecord::Base
  scope :shipping_info, lambda {
    where(name: 'shipping_info').first.value
  }
  scope :shipping_cost, lambda {
    where(name: 'shipping_cost').first.value
  }
  scope :tax, lambda {
    where(name: 'tax').first.value
  }
end
