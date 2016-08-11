class OrderPresenter
	class << self
		def to_csv(order_ids)
			orders = id_iterator(order_ids) do |item|
				item_to_csv(item)
			end
			orders.unshift(headers)
			orders.join("\n")
		end

		private

		def id_iterator(order_ids)
			order_ids.map do |id|
				order = Order.find(id)
				items = order.order_items.map do |item|
					yield item
				end
				items.join("\n")
			end
		end

		def headers
			'Order;Brand;Design;Product Type;Binding Color;Size;Qty;Mockup Front;Mockup Back;'\
			 'Image Front;Image Back;Order #;Order Paid;Item SKU;Item Name;Item Quantity;Item Unit Price;Item Size;'\
			  'Order Date;Order Total;Tax Paid;Shipping Paid;Buyer Full Name;Buyer Email;Buyer Username;Address;City;State;'\
			   'Postal Code;Country Code'
		end

		def item_to_csv(item)
			order = item.order
			"#{order.id};Sublimation Kitchen;Custom;#{item.product_template.product_type};"\
			 "#{item.template_variant.color.name};#{item.size};#{item.quantity};#{product_preview(item)};;"\
			 	 "#{item.product.uploaded_image};;#{order.id};#{order.purchased_at.try(:strftime,'%d/%m/%Y')};#{item.product.id};"\
			 	  "#{item.product.name};#{item.quantity};#{item.price};#{item.size};"\
			 	   "#{order.created_at.strftime('%d/%m/%Y')};#{order.total_cost};#{order.tax_cost};#{order.shipping_cost};"\
			 	    "#{order.full_name};#{order.email};"\
			 	     "#{order.user ? order.user.name : ''};#{order.address};"\
							"#{order.city};#{order.region};#{order.zip};"\
							 "#{order.country}"
		end

		def product_preview(item)
			Figaro.env.app_host + Refile.attachment_url(item.product, :preview, :fill, 400, 400, format: :png)
		end
	end
end
