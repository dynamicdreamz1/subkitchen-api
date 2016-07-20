class Invoice < ActiveRecord::Base
  belongs_to :order

	def pdf_url
		Figaro.env.app_host + "/api/v1/invoices?uuid=#{order.uuid}"
	end
end
