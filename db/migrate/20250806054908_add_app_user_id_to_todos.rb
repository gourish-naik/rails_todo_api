class AddAppUserIdToTodos < ActiveRecord::Migration[7.1]
  def change
    add_column :todos, :app_user_id, :integer
  end
end
