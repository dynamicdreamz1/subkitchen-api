ActiveAdmin.register User do
  actions :index, :show

  scope :all
  scope :artists
  scope :not_artists

  filter :email_cont, as: :string
  filter :name_cont, as: :string
  filter :status, as: :select, collection: %w[pending verified unverified]
  filter :email_confirmed
  filter :created_at
  filter :has_company



  index do
    column('Avatar') do |user|
      attachment_image_tag(user, :profile_image, :fit, 50, 50)
    end
    column(:email)
    column(:name)
    column(:artist)
    column(:status)
    actions
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
          table_for user.company do
            row(:company_name)
            row(:address)
            row(:region)
            row(:zip)
            row(:city)
            row(:country)
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
