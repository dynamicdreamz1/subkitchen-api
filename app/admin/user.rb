ActiveAdmin.register User do
  actions :index, :show

  scope :all
  scope :artists
  scope :not_artists
  scope :deleted

  filter :email_cont, as: :string
  filter :name_cont, as: :string
  filter :status, as: :select, collection: %w[pending verified unverified]
  filter :email_confirmed
  filter :created_at
  filter :has_company

  member_action :delete, method: :put do
    DeleteUser.new(resource).call
    resource.products.map{ |p| p.update(is_deleted: true) }
    redirect_to admin_users_path, notice: 'User Deleted'
  end

  index do
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
        link_to('Delete', delete_admin_user_path(user), method: :put, data: {confirm: 'Are you sure? If you delete this user, all the products created by this user will be deleted'})
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
            row('Number of Likes'){ user.likes_count }
            row('Number of Sales'){ user.sales_count }
            row('Profit'){ user.earnings_count }
            row('Published'){ user.published_count }
          end
        end
      end

      if user.has_company
        tab 'Company' do
          attributes_table do
            row('Company Name'){ user.company.company_name }
            row('Address'){ user.company.address }
            row('Region'){ user.company.region }
            row('Zip'){ user.company.zip }
            row('City'){ user.company.city }
            row('Country'){ user.company.country }
          end
        end
      end

      tab 'Orders' do
        table_for user.orders do
          column('Date') { |order| order.created_at.strftime('%d-%m-%Y')  }
          column(:order_status)
          column(:total_cost)
          column(''){ |order| link_to 'View', admin_order_path(order)}
        end
      end
    end
  end
end
