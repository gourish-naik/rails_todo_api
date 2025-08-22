# Complete Stripe Subscription Setup Guide

## 🏗️ Backend Setup (Docker)

### 1. Environment Variables
Make sure your `.env` file has:
```bash
STRIPE_SECRET_KEY=sk_test_your_secret_key_here
STRIPE_PUBLISHABLE_KEY=pk_test_your_publishable_key_here
STRIPE_PRICE_ID=price_your_price_id_here
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret_here
```

### 2. Start Your Docker Application
```bash
# Start your Rails API on port 3001
docker-compose up -d
# or
docker run -p 3001:3001 your-rails-app

# Verify it's running
curl http://localhost:3001/health
```

### 3. Setup Stripe Webhook Forwarding
```bash
# In a separate terminal, run this and keep it running
docker run --rm -it \
  -v ~/.config/stripe:/root/.config/stripe \
  stripe/stripe-cli:latest \
  listen --forward-to localhost:3001/api/webhooks

# You'll see output like:
# > Ready! Your webhook signing secret is whsec_xxxxx
# Copy this webhook secret to your .env file as STRIPE_WEBHOOK_SECRET
```

---

## 🧪 Testing Webhooks

### Test 1: Subscription Creation
```bash
docker run --rm -it \
  -v ~/.config/stripe:/root/.config/stripe \
  stripe/stripe-cli:latest \
  trigger checkout.session.completed \
  --add checkout_session:mode=subscription
```

### Test 2: Recurring Payment
```bash
docker run --rm -it \
  -v ~/.config/stripe:/root/.config/stripe \
  stripe/stripe-cli:latest \
  trigger invoice.payment_succeeded
```

### Test 3: Payment Failure
```bash
docker run --rm -it \
  -v ~/.config/stripe:/root/.config/stripe \
  stripe/stripe-cli:latest \
  trigger invoice.payment_failed
```

### Test 4: Subscription Cancellation
```bash
docker run --rm -it \
  -v ~/.config/stripe:/root/.config/stripe \
  stripe/stripe-cli:latest \
  trigger customer.subscription.deleted
```

---

## 🎯 Required API Endpoints

Add these endpoints to your Rails API:

### 1. Check Subscription Status
```ruby
# routes.rb
get '/api/subscription/status', to: 'subscriptions#status'

# app/controllers/api/subscriptions_controller.rb
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
```

### 2. Create Subscription Checkout
```ruby
# Already exists in your code - api/subscriptions#create
# Make sure it returns the checkout URL
```

### 3. Cancel Subscription
```ruby
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
```

---

## ⚛️ Frontend React Implementation

### 1. Create Subscription Hook
```javascript
// hooks/useSubscription.js
import { useState, useEffect } from 'react';

export const useSubscription = () => {
  const [subscription, setSubscription] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchSubscriptionStatus();
  }, []);

  const fetchSubscriptionStatus = async () => {
    try {
      const response = await fetch('http://localhost:3001/api/subscription/status', {
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('auth_token')}`,
          'Content-Type': 'application/json'
        }
      });
      const data = await response.json();
      setSubscription(data);
    } catch (error) {
      console.error('Error fetching subscription:', error);
      setSubscription({ subscribed: false });
    } finally {
      setLoading(false);
    }
  };

  const createSubscription = async () => {
    try {
      const response = await fetch('http://localhost:3001/api/subscriptions', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('auth_token')}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          success_url: `${window.location.origin}/subscription/success`,
          cancel_url: `${window.location.origin}/subscription/cancelled`
        })
      });
      const data = await response.json();
      
      if (data.url) {
        window.location.href = data.url; // Redirect to Stripe Checkout
      }
    } catch (error) {
      console.error('Error creating subscription:', error);
    }
  };

  return {
    subscription,
    loading,
    isSubscribed: subscription?.subscribed || false,
    createSubscription,
    refreshStatus: fetchSubscriptionStatus
  };
};
```

### 2. Subscription Guard Component
```javascript
// components/SubscriptionGuard.js
import React from 'react';
import { useSubscription } from '../hooks/useSubscription';

const SubscriptionGuard = ({ children, fallback }) => {
  const { isSubscribed, loading, createSubscription } = useSubscription();

  if (loading) {
    return <div>Loading subscription status...</div>;
  }

  if (!isSubscribed) {
    return fallback || (
      <div className="subscription-required">
        <h3>Subscription Required</h3>
        <p>You need an active subscription to access editing features.</p>
        <button 
          onClick={createSubscription}
          className="btn btn-primary"
        >
          Subscribe Now
        </button>
      </div>
    );
  }

  return children;
};

export default SubscriptionGuard;
```

### 3. Subscription Status Banner
```javascript
// components/SubscriptionBanner.js
import React from 'react';
import { useSubscription } from '../hooks/useSubscription';

const SubscriptionBanner = () => {
  const { subscription, isSubscribed, createSubscription } = useSubscription();

  if (isSubscribed) {
    return (
      <div className="alert alert-success">
        ✅ Active subscription (expires: {new Date(subscription.expires_at).toLocaleDateString()})
      </div>
    );
  }

  return (
    <div className="alert alert-warning">
      ⚠️ No active subscription - Limited to read-only access
      <button 
        onClick={createSubscription} 
        className="btn btn-sm btn-primary ml-2"
      >
        Subscribe
      </button>
    </div>
  );
};

export default SubscriptionBanner;
```

### 4. Usage in Your Components
```javascript
// In your main editing component
import React from 'react';
import { useSubscription } from '../hooks/useSubscription';
import SubscriptionGuard from '../components/SubscriptionGuard';
import SubscriptionBanner from '../components/SubscriptionBanner';

const EditingPage = () => {
  const { isSubscribed } = useSubscription();

  return (
    <div>
      <SubscriptionBanner />
      
      {/* Read-only content - always visible */}
      <div className="content">
        <h1>Your Content</h1>
        <p>This content is always visible...</p>
      </div>

      {/* Edit features - only for subscribers */}
      <SubscriptionGuard>
        <div className="edit-controls">
          <button>Edit</button>
          <button>Delete</button>
          <button>Create New</button>
        </div>
      </SubscriptionGuard>

      {/* Alternative: Conditional rendering */}
      {isSubscribed ? (
        <button className="btn-edit">Edit Mode</button>
      ) : (
        <button className="btn-disabled" disabled>
          Edit Mode (Subscription Required)
        </button>
      )}
    </div>
  );
};
```

---

## 🧪 Complete Testing Flow

### Step 1: Start Everything
```bash
# Terminal 1: Start your Rails API
docker-compose up

# Terminal 2: Start webhook forwarding (keep running)
docker run --rm -it -v ~/.config/stripe:/root/.config/stripe stripe/stripe-cli:latest listen --forward-to localhost:3001/api/webhooks

# Terminal 3: Start React frontend
npm start
```

### Step 2: Test User Journey

1. **Login as a user** in your React app
2. **Check subscription status**: Should show "not subscribed"
3. **Click "Subscribe"**: Should redirect to Stripe Checkout
4. **Complete test payment**: Use card `4242424242424242`
5. **Return to app**: Should now show "subscribed"
6. **Verify in database**: Check that subscription record was created

### Step 3: Test Webhooks
```bash
# Test subscription creation
docker run --rm -it -v ~/.config/stripe:/root/.config/stripe stripe/stripe-cli:latest trigger checkout.session.completed --add checkout_session:mode=subscription

# Check your Rails logs and database for new subscription record
```

---

## 🔍 Debugging Checklist

- [ ] Rails API is running on port 3001
- [ ] Webhook listener is running and connected
- [ ] All environment variables are set
- [ ] Database has `subscriptions` table with required fields
- [ ] User authentication is working in React
- [ ] CORS is configured for frontend requests

---

## 📝 Database Schema

Make sure your `subscriptions` table has these fields:

```ruby
# db/migrate/xxx_create_subscriptions.rb
create_table :subscriptions do |t|
  t.references :app_user, null: false, foreign_key: { to_table: :users }
  t.string :stripe_subscription_id, null: false
  t.string :stripe_customer_id
  t.string :status, default: 'incomplete'
  t.datetime :current_period_start
  t.datetime :current_period_end
  t.timestamps
end
```

And in your User model:
```ruby
class User < ApplicationRecord
  has_one :subscription, foreign_key: :app_user_id
  
  def subscribed?
    subscription&.active?
  end
end
```