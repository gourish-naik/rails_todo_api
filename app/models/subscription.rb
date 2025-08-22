class Subscription < ApplicationRecord
  belongs_to :app_user, class_name: 'AppUser'
  
  validates :stripe_subscription_id, presence: true, uniqueness: true
  
  enum status: {
    incomplete: 'incomplete',
    incomplete_expired: 'incomplete_expired',
    trialing: 'trialing',
    active: 'active',
    past_due: 'past_due',
    cancelled: 'cancelled',
    unpaid: 'unpaid'
  }

  def active?
    status == 'active' && current_period_end > Time.current
  end

  def expired?
    current_period_end && current_period_end < Time.current
  end

  def days_remaining
    return 0 unless current_period_end && active?
    ((current_period_end - Time.current) / 1.day).ceil
  end

end