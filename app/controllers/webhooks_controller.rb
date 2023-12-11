# frozen_string_literal: true

class WebhooksController < ApplicationController
  before_action :fetch_event

  def stripe
    case @event['type']
    when 'charge.succeeded'
      handle_charge_succeeded(@event['data']['object'])
    when 'charge.refunded'
      handle_charge_refunded(@event['data']['object'])
    else
      Rails.logger.error "Unhandled event type: #{@event['type']}"

      render json: {
        status: :fail,
        message: "Unhandled event type: #{@event['type']}"
      }, status: :bad_request
    end
  end

  private

  def handle_charge_succeeded(charge)
    Rails.logger.Info "Charge succeeded: #{charge['id']}"

    render json: {
      status: :success,
      message: 'Charge succeeded'
    }
  end

  def handle_charge_refunded(charge)
    Rails.logger.info "Charge refunded: #{charge['id']}"

    render json: {
      status: :success,
      message: 'Charge refunded'
    }
  end

  def fetch_event
    @event = Stripe::Webhook.construct_event(
      request.body.read,
      request.env['HTTP_STRIPE_SIGNATURE'],
      ENV['STRIPE_WEBHOOK_SECRET']
    )
  rescue JSON::ParserError => e
    render json: { error: e.message }, status: :bad_request
  rescue Stripe::SignatureVerificationError => e
    render json: { error: e.message }, status: :bad_request
  end
end
