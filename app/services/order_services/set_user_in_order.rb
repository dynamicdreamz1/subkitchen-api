class SetUserInOrder
  def call
    set_user
  end

  private

  attr_reader :user, :order_uuid

  def initialize(user, order_uuid)
    @user = user
    @order_uuid = order_uuid
  end

  def set_user
    order = Order.find_by(uuid: order_uuid)
    return false unless order
    order.update(user: user)
  end
end