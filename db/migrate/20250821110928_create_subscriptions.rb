class CreateSubscriptions < ActiveRecord::Migration[7.1]
  def change
    create_table :subscriptions do |t|
      t.references :app_user, null: false, foreign_key: { to_table: :users }
      t.string :stripe_subscription_id, null: false
      t.string :stripe_customer_id
      t.string :status, default: 'incomplete'
      t.datetime :current_period_start
      t.datetime :current_period_end
      t.timestamps

    end
    add_index :subscriptions, :stripe_subscription_id, unique: true
  end
end

