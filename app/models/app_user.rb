class AppUser < ApplicationRecord
	validates :username, presence: true, uniqueness: true
	validates :password, presence: true

	has_many :user_logins, foreign_key: 'user_id', dependent: :destroy
	has_many :todos, foreign_key: 'app_user_id', dependent: :destroy
	has_many :subscriptions, dependent: :destroy
	has_one :subscription, foreign_key: :app_user_id, dependent: :destroy

	def subscribed?
    subscription&.active?
  end

  def subscription_status
    return 'none' unless subscription
    subscription.status
  end

  def subscription_expires_at
    subscription&.current_period_end
  end

	def generate_tokens
		access_token = SecureRandom.hex(32)
		refresh_token = SecureRandom.hex(32)

		{
			access_token: access_token,
			refresh_token: refresh_token,
			token_exp_time: 1.hour.from_now,
			ref_token_exp_time: 7.days.from_now
		}
	end

	def create_login_session
		tokens = generate_tokens 

		UserLogin.create!(
			user_id: self.id,
			username: username,
			token: tokens[:access_token],
			refresh_token: tokens[:refresh_token],
			token_exp_time: tokens[:token_exp_time],
			ref_token_exp_time: tokens[:ref_token_exp_time]
		)

		tokens
	end

end
