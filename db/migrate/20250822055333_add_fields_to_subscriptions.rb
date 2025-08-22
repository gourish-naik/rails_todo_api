class AddFieldsToSubscriptions < ActiveRecord::Migration[7.1]
  def change
    add_column :subscriptions, :stripe_customer_id, :string
    add_column :subscriptions, :current_period_start, :datetime
    add_column :subscriptions, :current_period_end, :datetime
  end
end