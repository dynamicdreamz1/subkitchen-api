class OrderCancellationCallback
	def after_update(record)
		update_sales_and_earnings_counters(record) if record.cancelled?
	end

	private

	def update_sales_and_earnings_counters(order)
		SalesAndEarningsDecrementCounter.perform_async(order.id)
	end
end