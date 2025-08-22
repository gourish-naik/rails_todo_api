# app/controllers/api/webhooks_controller.rb
class Api::WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!

  # disable layout rendering for API
  protect_from_forgery with: :null_session

  def create
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = ENV['STRIPE_WEBHOOK_SECRET']

    event = nil
    begin
      if endpoint_secret.present?
        event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
      else
        event = JSON.parse(payload, symbolize_names: true)
      end
    rescue JSON::ParserError => e
      Rails.logger.error("Webhook JSON parse error: #{e.message}")
      return head :bad_request
    rescue Stripe::SignatureVerificationError => e
      Rails.logger.error("Webhook signature verification failed: #{e.message}")
      return head :bad_request
    end

    handle_event(event)
    head :ok
  end

  private

  def handle_event(event)
    case event['type']
    when 'checkout.session.completed'
      session = event['data']['object']
      handle_checkout_completed(session)

    when 'customer.subscription.created',
         'customer.subscription.updated'
      subscription = event['data']['object']
      handle_subscription_update(subscription)

    when 'invoice.paid'
      invoice = event['data']['object']
      Rails.logger.info("Invoice paid for subscription #{invoice['subscription']}")
      # Optional: mark payment success in DB

    when 'invoice.payment_failed'
      invoice = event['data']['object']
      Rails.logger.warn("Invoice payment failed for #{invoice['subscription']}")
      sub = Subscription.find_by(stripe_subscription_id: invoice['subscription'])
      sub&.update(status: 'payment_failed')

    else
      Rails.logger.info("Unhandled event type: #{event['type']}")
    end
  end

  def handle_checkout_completed(session)
    user_id = session['client_reference_id'] || session.dig('metadata', 'user_id')
    stripe_sub_id = session['subscription']

    return unless user_id && stripe_sub_id

    sub = Subscription.find_or_initialize_by(app_user_id: user_id)
    sub.update(
      stripe_subscription_id: stripe_sub_id,
      status: 'active'
    )
    Rails.logger.info("Checkout completed: user=#{user_id} sub=#{stripe_sub_id}")
  end

  def handle_subscription_update(subscription)
    sub = Subscription.find_by(stripe_subscription_id: subscription['id'])
    return unless sub

    sub.update(
      status: subscription['status'],
      current_period_end: Time.at(subscription['current_period_end'])
    )
    Rails.logger.info("Subscription #{sub.id} updated to #{sub.status}")
  end
end
