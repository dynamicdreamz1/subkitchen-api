class PayoutListSerializer
  def as_json(options = {})
    data = {
      payouts: serialized_payouts,
      meta: {
        current_page: payouts.current_page,
        total_pages: payouts.total_pages
      }
    }

    data.as_json(options)
  end

  private

  attr_accessor :payouts

  def initialize(payouts)
    @payouts = payouts
  end

  def serialized_payouts
    payouts.map do |payout|
      single_payout = single_payout(payout)

      single_payout[:errors] = payout.errors if payout.errors.any?
      single_payout
    end
  end

  def single_payout(payout)
    {
      id:         			   payout.id,
			value:      				 payout.value,
      created_at: 		     payout.created_at
    }
  end
end
