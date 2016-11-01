module SalesAndEarningsMethods
	def profit(item)
		coupon = item.order.coupon
		if coupon
			discount = if coupon.percentage
				coupon.discount
			else
				(100 * coupon.discount) / item.order.subtotal_cost
			end
			return (item.profit - item.profit * 0.01 * discount).round(2)
		end
		(item.price * 0.2).round
	end

	def get_order(order_id)
		Order.find_by(id: order_id)
	end

	def get_user(item)
		item.product.author
	end

	def get_earnings_count(user)
		$redis.get("user_#{user.id}_earnings_counter").to_f
	end

	def get_sales_counter(user)
		$redis.get("user_#{user.id}_sales_counter").to_i
	end

	def set_earnings_weekly(user, earnings_percentage)
		$redis.set("user_#{user.id}_earnings_weekly", earnings_percentage)
	end

	def set_sales_weekly(user, sales_percentage)
		$redis.set("user_#{user.id}_sales_weekly", sales_percentage)
	end

	def calculate_earnings_percentage(user)
		count = get_earnings_count(user)
		return 0 if count == 0
		(earnings_count_weekly(user) * 100) / count
	end

	def calculate_sales_percentage(user)
		count = get_sales_counter(user)
		return 0 if count == 0
		(sales_count_weekly(user) * 100) / count
	end

	def sales_count_weekly(user)
		OrderItem.joins('RIGHT JOIN orders ON orders.id = order_items.order_id')
			.where('orders.purchased_at > ?', 1.week.ago)
			.joins('RIGHT  JOIN products ON products.id = order_items.product_id')
			.where('products.author_id = ?', user.id)
			.sum('order_items.quantity')
	end

	def earnings_count_weekly(user)
		OrderItem.joins('RIGHT JOIN orders ON orders.id = order_items.order_id')
			.joins('RIGHT  JOIN products ON products.id = order_items.product_id')
			.where('products.author_id = ?', user.id)
			.where('orders.purchased_at > ?', 1.week.ago)
			.sum('order_items.quantity*order_items.profit')
	end
end
