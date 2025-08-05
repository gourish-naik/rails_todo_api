class ModifyUsersTable < ActiveRecord::Migration[7.1]
   def change
    remove_column :users, :email, :string    
    rename_column :users, :password_digest, :password
  end
end
