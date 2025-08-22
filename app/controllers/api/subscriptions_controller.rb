class Api::SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_stripe_key

  def create
    price_id = ENV['STRIPE_PRICE_ID']

    session = Stripe::Checkout::Session.create(
      payment_method_types: ['card'],
      line_items: [{
        price: price_id,
        quantity: 1,
      }],
      mode: 'subscription',
      success_url: params[:success_url] || 'http://localhost:3000/success',
      cancel_url: params[:cancel_url] || 'http://localhost:3000/cancel',
      client_reference_id: current_user.id,
      metadata: {
        user_id: current_user.id,
        user_email: current_user.username
      }
    )

    render json: { url: session.url }
  end

  def status
    subscription = current_user.subscription
    
    if subscription&.active?
      render json: { 
        subscribed: true, 
        status: subscription.status,
        expires_at: subscription.current_period_end 
      }
    else
      render json: { 
        subscribed: false, 
        status: subscription&.status || 'none' 
      }
    end
  end

  def cancel
    subscription = current_user.subscription
    
    if subscription&.stripe_subscription_id
      Stripe::Subscription.update(
        subscription.stripe_subscription_id,
        { cancel_at_period_end: true }
      )
      render json: { success: true, message: 'Subscription will cancel at period end' }
    else
      render json: { error: 'No active subscription found' }, status: 404
    end
  end

  private

  def set_stripe_key
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
    
    if Stripe.api_key.blank?
      render json: { error: 'Stripe configuration error - API key missing' }, status: 500
      return
    end
  end
end