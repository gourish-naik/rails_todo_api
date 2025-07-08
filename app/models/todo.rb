class Todo < ApplicationRecord
  validates :todo_name, presence: true
end
