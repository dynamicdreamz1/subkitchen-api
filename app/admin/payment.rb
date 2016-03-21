ActiveAdmin.register Payment do
  config.batch_actions = false
  actions :index

  scope :completed
  scope :denied
  scope :pending
  scope :malformed

  filter :created_at
  filter :payment_type, as: :select, collection: %w[stripe paypal]
  filter :id_cont, as: :string, label: 'ID'
  filter :payment_token_cont, as: :string, label: 'Token'

  index do
    column('Order/Verification') { |payment| link_to payment.payable_type, "/admin/#{payment.payable_type.downcase}s/#{payment.payable_id}" }
    column(:created_at)
    column(:payment_status)
    column(:payment_type)
    column(:payment_token)
  end
end
