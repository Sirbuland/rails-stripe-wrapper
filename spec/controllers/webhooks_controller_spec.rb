# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WebhooksController, type: :controller do
  describe '#stripe' do
    let(:webhook_secret) { ENV['STRIPE_WEBHOOK_SECRET'] }
    let(:valid_payload) { { 'type' => 'charge.succeeded', 'data' => { 'object' => { 'id' => 'charge_id' } } } }
    let(:invalid_payload) { { 'type' => 'invalid.event.type', 'data' => { 'object' => { 'id' => 'invalid_id' } } } }

    context 'with a valid signature' do
      before do
        allow(Stripe::Webhook).to receive(:construct_event).and_return(valid_payload)
      end

      it 'handles charge succeeded event' do
        post :stripe, body: valid_payload.to_json

        expect(response).to have_http_status(:success)
        expect(response.body).to eq({ status: :success, message: 'Charge succeeded' }.to_json)
      end

      it 'handles charge refunded event' do
        valid_payload['type'] = 'charge.refunded'
        post :stripe, body: valid_payload.to_json

        expect(response).to have_http_status(:success)
        expect(response.body).to eq({ status: :success, message: 'Charge refunded' }.to_json)
      end

      it 'handles unhandled event type' do
        valid_payload['type'] = 'invalid.event.type'
        post :stripe, body: valid_payload.to_json

        expect(response).to have_http_status(:bad_request)
        expect(response.body).to eq({ status: :fail, message: 'Unhandled event type: invalid.event.type' }.to_json)
      end
    end

    context 'with an invalid signature' do
      before do
        allow(Stripe::Webhook).to receive(:construct_event).and_raise(Stripe::SignatureVerificationError.new(
                                                                        'Invalid signature', 'sig_header'
                                                                      ))
      end

      it 'returns bad request with invalid signature error' do
        post :stripe, body: valid_payload.to_json

        expect(response).to have_http_status(:bad_request)
        expect(response.body).to eq({ error: 'Invalid signature' }.to_json)
      end
    end

    context 'with JSON parser error' do
      before do
        allow(Stripe::Webhook).to receive(:construct_event).and_raise(JSON::ParserError, 'Invalid JSON')
      end

      it 'returns bad request with JSON parser error' do
        post :stripe, body: 'invalid_json'

        expect(response).to have_http_status(:bad_request)
        expect(response.body).to eq({ error: 'Invalid JSON' }.to_json)
      end
    end
  end
end
