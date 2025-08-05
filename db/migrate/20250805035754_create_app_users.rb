class CreateAppUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :app_users do |t|
      t.string :username
      t.string :password

      t.timestamps
    end
  end
end
