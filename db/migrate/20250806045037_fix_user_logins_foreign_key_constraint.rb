class FixUserLoginsForeignKeyConstraint < ActiveRecord::Migration[7.1]
  def change
    # Remove the existing foreign key constraint
    remove_foreign_key :user_logins, :users
    
    # Add the correct foreign key constraint pointing to app_users
    add_foreign_key :user_logins, :app_users, column: :user_id
  end
end