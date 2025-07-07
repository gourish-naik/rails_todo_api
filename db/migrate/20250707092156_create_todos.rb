class CreateTodos < ActiveRecord::Migration[7.1]
  def change
    create_table :todos do |t|
      t.string :todo_name
      t.boolean :completed

      t.timestamps
    end
  end
end
