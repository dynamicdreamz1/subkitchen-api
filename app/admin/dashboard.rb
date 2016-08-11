ActiveAdmin.register_page 'Dashboard' do
  menu priority: 1, label: proc { I18n.t('active_admin.dashboard') }

  content title: proc { I18n.t('active_admin.dashboard') } do
    columns do
      column do
        panel 'Recent Orders' do
          table_for Order.fulfilled.order('purchased_at desc').limit(10) do
            column('Customer') do |order|
              if order.user
                link_to(order.user.email, admin_user_path(order.user))
              else
                'unknown'
              end
            end
            column('Total', &:total_cost)
            column('') { |order| link_to 'View', admin_order_path(order) }
          end
        end
      end

      column do
        panel 'Recent Users' do
          table_for User.order('id desc').limit(10).each do
            column('Avatar') do |user|
              image_tag(user.profile_image, height: '30')
            end
            column(:name)
            column(:email) { |user| link_to(user.email, admin_user_path(user)) }
          end
        end
      end
    end

    columns do
      column do
        panel 'Recently published' do
          table_for Product.published_all.order('published_at desc').limit(10) do
            column('Image') do |product|
              attachment_image_tag(product, :image, :fit, 50, 50)
            end
            column(:author)
            column(:name) { |product| link_to(product.name, admin_product_path(product)) }
          end
        end
      end

      column do
        panel 'BestSellers' do
          table_for Product.order('order_items_count desc').limit(10) do
            column('Image') do |product|
              attachment_image_tag(product, :image, :fit, 50, 50)
            end
            column(:author)
            column(:name) { |product| link_to(product.name, admin_product_path(product)) }
          end
        end
      end
    end
  end
end
