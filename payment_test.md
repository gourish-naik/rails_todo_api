Here's your guide to test Stripe Payments:

```
# Testing Your Stripe Integration with Postman (Rails + Docker Setup)

This guide walks you through testing your Stripe subscription flow using **Postman** and the **Stripe CLI**.

---

## Step 1: Start Your Rails Server

Make sure your Rails application is running. If you're using Docker, start your server with:

```bash
docker compose up

```

* * * * *

Step 2: Set Your Environment Variables
--------------------------------------

Before starting, set the following environment variables in your application:

-   **STRIPE_PRICE_ID**: Get this from your Stripe Dashboard under **Products > Prices**.

-   **STRIPE_WEBHOOK_SECRET**: You'll get this in **Step 5**.

If you're using a `.env` file, add them there. Otherwise, you can set them inline when starting the server:

```
STRIPE_PRICE_ID=your_price_id STRIPE_WEBHOOK_SECRET=your_webhook_secret docker compose up

```

* * * * *

Step 3: Create a User and Get an Authentication Token
-----------------------------------------------------

Your `/api/subscriptions` endpoint is protected, so you need an authentication token first.

1.  Open **Postman** and create a new **POST** request:

    ```
    http://localhost:3000/api/users

    ```

2.  In the **Body** tab, select **raw** → **JSON**, and add:

    ```
    {
      "username": "testuser",
      "password": "password"
    }

    ```

3.  Click **Send**.\
    The response will contain an `access_token`. Copy this token for the next step.

* * * * *

Step 4: Create a Subscription Checkout Session
----------------------------------------------

Now, let's create a **Stripe Checkout session**.

1.  Create a new **POST** request in Postman:

    ```
    http://localhost:3000/api/subscriptions

    ```

2.  In the **Headers** tab, add:

    ```
    Key: Authorization
    Value: Bearer <your_access_token>

    ```

    (replace `<your_access_token>` with the token from Step 3)

3.  (Optional) Provide custom success and cancel URLs in the request body:

    ```
    {
      "success_url": "https://your-frontend.com/success",
      "cancel_url": "https://your-frontend.com/cancel"
    }

    ```

4.  Click **Send**.\
    The response will contain a `url` → this is the Stripe Checkout page.

* * * * *

Step 5: Test the Webhook with the Stripe CLI
--------------------------------------------

Use the Stripe CLI to verify your webhook is working correctly.

1.  Install the **Stripe CLI**:\
    [Stripe CLI Installation Guide](https://stripe.com/docs/stripe-cli)

2.  Log in to Stripe via CLI:

    ```
    stripe login

    ```

3.  Forward webhook events to your local server:

    ```
    stripe listen --forward-to localhost:3000/api/webhooks

    ```

    This command will also provide a **webhook signing secret** (`whsec_...`).

4.  Copy the webhook secret and set it as `STRIPE_WEBHOOK_SECRET` (see Step 2).\
    Restart your server for the new environment variable to load.

5.  Trigger a test event:

    -   Open the **Stripe Checkout URL** you got from Postman in your browser.

    -   Use one of Stripe's [test cards](https://stripe.com/docs/testing#cards) to complete payment.

✅ Once the payment is complete:

-   You'll see a `checkout.session.completed` event in the terminal running `stripe listen`.

-   Your Rails server logs should show something like:\
    `"Subscription created for user..."` → confirming your webhook is working.

* * * * *
