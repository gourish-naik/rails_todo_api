class Todo < ApplicationRecord
  belongs_to :app_user, foreign_key: 'app_user_id'
  
  validates :app_user_id, presence: true
  validates :todo_name, presence: true
end
