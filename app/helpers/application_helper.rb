module ApplicationHelper
  def number_to_price(number)
    ActionController::Base.helpers.number_with_precision(number, precision: 2)
  end
end
