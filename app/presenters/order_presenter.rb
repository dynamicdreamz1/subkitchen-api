class OrderPresenter
	class << self
		def to_shipping_csv(order_ids)
			orders = id_iterator(order_ids) do |item|
				item_to_shipping_csv(item)
			end
			orders.unshift(shipping_headers)
			orders.join('')
		end

		def to_t6_csv(order_ids)
			orders = id_iterator(order_ids) do |item|
				item_to_t6_csv(item)
			end
			orders.unshift(t6_headers)
			orders.join('')
		end

		private

		def id_iterator(order_ids)
			order_ids.map do |id|
				order = Order.find(id)
				items = order.order_items.map do |item|
					yield item
				end
				items.join('\n')
			end
		end

		def shipping_headers
			'Order+#,Order+Paid,Product+Id,Product+Name,Product+Quantity,Product+Price,Product+Size,'\
			 'Order+Date,Order+Total,Tax+Paid,Shipping+Paid,Buyer+Full+Name,Buyer+Email,Buyer+Username,Address,City,State,'\
				'Postal+Code,Country+Code\n'
		end

		def t6_headers
			'Order,Brand,Design,Product+Type,Binding+Color,Size,Qty,Mockup+Front,Mockup+Back,'\
			 'Image+Front,Image+Back\n'
		end

		def item_to_shipping_csv(item)
			order = item.order
			"#{order.id},#{order.purchased_at.try(:strftime,'%d/%m/%Y')},#{item.product.id},"\
			 "#{CGI::escape(item.product.name)},#{item.quantity},#{item.price},#{item.size},"\
			  "#{order.created_at.strftime('%d/%m/%Y')},#{order.total_cost},#{order.tax_cost},#{order.shipping_cost},"\
			   "#{CGI::escape(order.full_name)},#{CGI::escape(order.email)},"\
			    "#{CGI::escape(order.user ? order.user.name : 'anonymous user')},#{CGI::escape(order.address)},"\
			     "#{CGI::escape(order.city)},#{CGI::escape(order.region)},#{CGI::escape(order.zip)},"\
			      "#{CGI::escape(order.country)}"
		end

		def item_to_t6_csv(item)
			order = item.order
			"#{order.id},Sublimation+Kitchen,Custom,#{CGI::escape(item.template_variant.product_template.product_type)},"\
			 "#{CGI::escape(item.template_variant.color.name)},#{item.size},#{item.quantity},#{product_preview(item)},,"\
				"#{item.product.uploaded_image},,"
		end

		def product_preview(item)
			Figaro.env.app_host + Refile.attachment_url(item.product, :preview, :fill, 400, 400, format: :png)
		end
	end
end
