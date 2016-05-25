ActiveAdmin.register NewsletterReceiver do
  config.sort_order = 'id_asc'
  permit_params :email
  config.filters = false
  config.batch_actions = true
  actions :all, except: [:show]

  index do
    selectable_column
    column(:id)
    column(:email)
    column('Join Date', &:created_at)
    actions
  end

  form do |f|
    f.inputs 'Add To Newsletter' do
      f.input :email
      f.actions
    end
  end
end
