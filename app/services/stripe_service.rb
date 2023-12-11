# frozen_string_literal: true

class StripeService
  def initialize
    Stripe.api_key = ENV['STRIPE_API_KEY']
  end

  def create_charge(amount, currency = 'usd')
    Stripe::Charge.create({
                            amount:,
                            currency:,
                            source: 'tok_visa', # This should be user payment method
                            description: 'Charge created with StripeService'
                          })
  rescue Stripe::StripeError => e
    handle_error(e, 'StripeError while creating charge')
  rescue StandardError => e
    handle_error(e, 'UnexpectedError while creating charge')
  end

  def refund_charge(id)
    Stripe::Refund.create(charge: id)
  rescue Stripe::StripeError => e
    handle_error(e, 'StripeError while refunding charge')
  rescue StandardError => e
    handle_error(e, 'UnexpectedError while refunding charge')
  end

  private

  def handle_error(error, message)
    Rails.logger.error("#{message}: #{error.message}")

    # Using Struct to be able to use dot notation in parent
    OpenStruct.new(status: 'failed', message: "#{message}: #{error.message}")
  end
end
