class GootenSerializer
  include ApplicationHelper

  def as_json(options = {})
    data = {
      'ShipToAddress': ship_to_address,
      'BillingAddress': billing_address,
      'Items': items,
    }

    data.as_json(options)
  end

  private

  attr_reader :order

  def initialize(order)
    @order = order
  end

  def ship_to_address
    {
      'FirstName': name[0],
      'LastName': name[1...-1].join(' '),
      'Line1': order.address,
      'City': order.city,
      'State': order.region,
      'CountryCode': order.country,
      'PostalCode': order[:zip],
      'IsBusinessAddress': 'false',
      'Phone': '2126289181',
      'Email': order.email
    }
  end

  def billing_address
    {
      'FirstName': name[0],
      'LastName': name[1...-1].join(' '),
      'Line1': order.address,
      'City': order.city,
      'State': order.region,
      'CountryCode': order.country,
      'PostalCode': order[:zip],
      'IsBusinessAddress': 'false',
      'Phone': '2126289181',
      'Email': order.email
    }
  end

  def name
    order.full_name.split(' ')
  end

  def items
    order.order_items.map do |item|
      {
        'Quantity': item.quantity,
        'SKU': 'CanvsWrp-BlkWrp-12x12',
        'ShipCarrierMethodId': '1', #Id received from the Shipping Estimates method.
        'Images': [{
                     'Url': Figaro.env.app_host + Refile.attachment_url(item.product, :image),
                     'ThumbnailUrl': Figaro.env.app_host + Refile.attachment_url(item.product, :preview),
                   }],
        'SourceId': item.id,
      }
    end

    def country
      IsoCountryCodes.search_by_name(order.country).alpha2
    end
  end
end