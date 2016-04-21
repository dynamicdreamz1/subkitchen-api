ActiveAdmin.register Coupon do
  permit_params :description,
                :code,
                :discount,
                :valid_from,
                :valid_until,
                :percentage,
                :redemption_limit,
                :redeemed
  config.filters = false
  config.batch_actions = false
  actions :all

  index do
    column(:id)
    column(:discount)
    column(:percentage)
    column(:description)
    column(:code)
    column(:redemption_limit)
    column(:valid_from)
    column(:valid_until)
    column(:redeemed)
  end

  show do
    attributes_table do
      row(:discount)
      row(:percentage)
      row(:description)
      row(:code)
      row(:redemption_limit)
      row(:valid_from)
      row(:valid_until)
      row(:redeemed)
    end
  end

  form do |f|
    f.inputs 'Coupon' do
      f.input :discount
      f.input :percentage
      f.input :description
      f.input :code
      f.input :redemption_limit
      f.input :valid_from, as: :date_time_picker
      f.input :valid_until, as: :date_time_picker
      f.actions
    end
  end
end
