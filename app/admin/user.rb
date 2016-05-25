ActiveAdmin.register User do
  actions :index, :show, :new, :create
  config.sort_order = 'id_asc'

  scope :all
  scope :artists
  scope :not_artists
  scope :deleted

  filter :email_cont, as: :string
  filter :name_cont, as: :string
  filter :status, as: :select, collection: %w(pending verified unverified)
  filter :email_confirmed
  filter :created_at

  member_action :delete, method: :put do
    DeleteUser.new(resource).call
    resource.products.map { |p| p.update(is_deleted: true) }
    redirect_to admin_users_path, notice: 'User Deleted'
  end

  form do |f|
    f.inputs 'User', multipart: true do
      f.input :profile_image, as: :refile
      f.input :name, required: true
      f.input :email, required: true
      f.input :handle, required: true
      f.input :password, required: true
      f.input :password_confirmation, required: true
      f.input :email_confirmed, input_html: { value: true }, as: :hidden
      f.input :artist
      f.input :status, input_html: { value: :verified }, as: :hidden
    end
    f.inputs 'Address' do
      f.input :first_name
      f.input :last_name
      f.input :address
      f.input :city
      f.input :zip
      f.input :region
      f.input :country, as: :select, collection: IsoCountryCodes.for_select
      f.input :phone
    end
    f.inputs 'Company' do
      f.input :shop_banner, as: :refile
      f.has_many :company do |c|
        c.input :company_name
        c.input :address
        c.input :city
        c.input :zip
        c.input :region
        c.input :country, as: :select, collection: IsoCountryCodes.for_select
      end
    end
    f.actions
  end

  controller do
    def permitted_params
      params.permit!
    end
  end

  index do
    column(:id)
    column('Avatar') do |user|
      attachment_image_tag(user, :profile_image, :fit, 50, 50)
    end
    column(:name)
    column(:email)
    column(:artist)
    column(:status)
    actions defaults: false do |user|
      unless user.is_deleted
        link_to('View', admin_user_path(user), method: :get) + ' ' +
          link_to('Delete', delete_admin_user_path(user), method: :put,
                  data: { confirm: 'Are you sure? If you delete this user,
                                    all the products created by this user will be deleted' })
      end
    end
  end

  show do |user|
    tabs do
      tab('Overview') do
        attributes_table do
          row('Avatar') do
            attachment_image_tag(user, :profile_image, :fit, 50, 50)
          end
          row(:email)
          row(:email_confirmed)
          row(:name)
          row(:artist)
          row(:status)
          row(:created_at)
        end
      end

      tab 'Shipping address' do
        attributes_table do
          row(:first_name)
          row(:last_name)
          row(:address)
          row(:region)
          row(:zip)
          row(:city)
          row(:country)
          row(:phone)
        end
      end

      if user.artist
        tab 'Shop' do
          attributes_table do
            row(:handle)
            row('Number of Likes') { user.likes_count }
            row('Number of Sales') { user.sales_count }
            row('Profit') { user.earnings_count }
            row('Published') { user.published_count }
          end
        end
      end

      if user.company
        tab 'Company' do
          attributes_table do
            row('Company Name') { user.company.company_name }
            row('Address') { user.company.address }
            row('Region') { user.company.region }
            row('Zip') { user.company.zip }
            row('City') { user.company.city }
            row('Country') { user.company.country }
          end
        end
      end

      tab 'Orders' do
        table_for user.orders do
          column('Date') { |order| order.created_at.strftime('%d-%m-%Y') }
          column(:order_status)
          column(:total_cost)
          column(:payment)
          column('') { |order| link_to 'View', admin_order_path(order) }
        end
      end

      if user.payment
        tab 'Verification' do
          attributes_table do
            row('Created At') { user.payment.created_at }
            row('Status') { user.payment.payment_status }
            row('Type') { user.payment.payment_type }
            row('Token') { user.payment.payment_token }
          end
        end
      end
    end
  end
end
