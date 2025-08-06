
class CreateUserLogins < ActiveRecord::Migration[7.1]
  def change
    create_table :user_logins do |t|
      t.references :user, null: false, foreign_key: { to_table: :app_users }
      t.string :username
      t.string :token
      t.string :refresh_token
      t.datetime :token_exp_time
      t.datetime :ref_token_exp_time

      t.timestamps
    end
    
    add_index :user_logins, :token
    add_index :user_logins, :refresh_token
    add_index :user_logins, :username
  end
end