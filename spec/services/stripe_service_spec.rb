# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StripeService do
  let(:stripe_service) { StripeService.new }

  describe '#create_charge' do
    it 'creates a charge successfully' do
      VCR.use_cassette :create_charge_success do
        result = stripe_service.create_charge(1000, 'usd')

        expect(result.status).to eq('succeeded')
        expect(result.description).to eq('Charge created with StripeService')
      end
    end

    it 'handles Stripe error during charge creation' do
      VCR.use_cassette :create_charge_stripe_error do
        result = stripe_service.create_charge(1, 'usd')

        expect(result.status).to eq('failed')
        expect(result.message).to eq('StripeError while creating charge: Amount must be at least $0.50 usd')
      end
    end

    it 'handles unexpected error during charge creation' do
      allow(Stripe::Charge).to receive(:create).and_raise(StandardError, 'Unexpected error')

      result = stripe_service.create_charge(1000, 'usd')

      expect(result.status).to eq('failed')
      expect(result.message).to eq('UnexpectedError while creating charge: Unexpected error')
    end
  end

  describe '#refund_charge' do
    it 'refunds a charge successfully' do
      VCR.use_cassette :refund_charge_success do
        result = stripe_service.refund_charge('ch_test123')

        expect(result.status).to eq('succeeded')
      end
    end

    it 'handles Stripe error during charge refund' do
      VCR.use_cassette :refund_charge_stripe_error do
        result = stripe_service.refund_charge('ch_test123')

        expect(result.status).to eq('failed')
        expect(result.message).to eq("StripeError while refunding charge: No such charge: 'ch_test123'")
      end
    end

    it 'handles unexpected error during charge refund' do
      allow(Stripe::Refund).to receive(:create).and_raise(StandardError, 'Unexpected error')
      result = stripe_service.refund_charge('ch_test123')

      expect(result.status).to eq('failed')
      expect(result.message).to eq('UnexpectedError while refunding charge: Unexpected error')
    end
  end
end
