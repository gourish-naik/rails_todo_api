class UserLogin < ApplicationRecord
  # belongs_to :user, class_name: 'AppUser',  foreign_key: 'user_id'

  validates :username, presence: true
  validates :refresh_token, presence: true
  validates :user_id, presence: true  # Add this instead

  scope :active_tokens, -> { where('token_exp_time > ?', Time.current)}
  scope :active_refresh_token, -> { where('ref_token_exp_time > ?', Time.current)}
end
