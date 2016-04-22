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
  config.batch_actions = true
  actions :all

  action_item :generate do
     link_to 'Generate Coupons', generate_coupons_form_admin_coupons_path, method: :get
  end

  collection_action :generate_coupons_form, method: :get do
    @coupon = Coupon.new
    def @coupon.amount ; end
  end

  collection_action :generate_coupons, method: :post do
    params['coupon']['amount'].to_i.times do
      Coupon.create!(
          discount: params['coupon']['discount'],
          percentage: params['coupon']['percentage'],
          description: params['coupon']['description'],
          redemption_limit: params['coupon']['redemption_limit'],
          valid_from: params['coupon']['valid_from'],
          valid_until: params['coupon']['valid_until']
      )
    end
    redirect_to admin_coupons_path, notice: "Created #{params['coupon']['amount']} coupons!"
  end

  index do
    selectable_column
    column(:id)
    column(:discount)
    column(:percentage)
    column(:description)
    column(:code)
    column('Redemption Count') do |coupon|
      coupon.redemptions_count
    end
    column(:redemption_limit)
    column(:valid_from)
    column(:valid_until)
    column(:redeemed)
    actions
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
