# README

* Ruby version
  - 3.2.2

* Rails version
  - 7.1.2

* How to run the test suite
  - bundle exec rspec

* Setup environment variables
  - Create .env file at root directory and add these environment variables in it
  ```
  STRIPE_API_KEY = YOUR_STRIPE_API_KEY
  STRIPE_WEBHOOK_SECRET = YOUR_STRIPE_WEBHOOK_SECRET
  ```

* Setup stripe webhook
  - Need to create webhook on stripe for charge.succeeded and charge.refunded events
