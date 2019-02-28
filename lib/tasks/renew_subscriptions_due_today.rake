desc "It will submit payment for all Subscriptions whose next_billing_date is today."
task renew_subscriptions_due_today: :environment do
  Subscription.where(next_billing_date: Date.today).find_each do |sub|
    payment_response = sub.renew_payment

    if !payment_response[:success]
      Rails.logger.error "Subscription Renewal Failed (id: #{sub.id}): #{payment_response[:errors]}"
    end
  end
end
