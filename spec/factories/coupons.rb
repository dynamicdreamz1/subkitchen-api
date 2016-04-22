FactoryGirl.define do
  factory :coupon do
    description 'Coupon'
    code SecureRandom.hex(3)
    discount 20
    valid_from DateTime.now
    valid_until DateTime.now + 2.days

    trait :percentage do
      percentage true
    end

    trait :no_limit do
      redemption_limit 0
    end

    trait :one_time_limit do
      redemption_limit 1
    end
  end
end
