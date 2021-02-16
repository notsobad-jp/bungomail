class User < ApplicationRecord
  authenticates_with_sorcery!
  has_one :membership, foreign_key: :id, dependent: :destroy
  has_many :membership_logs, dependent: :destroy
  has_many :channels, dependent: :destroy

  delegate :stripe_customer_id, :stripe_subscription_id, :plan, :status, to: :membership, allow_nil: true

  # activation実行に必要なのでダミーのパスワードを設定
  ## before_validateでcryptedの作成処理が走るので、それより先に用意できるようにafter_initializeを使用
  after_initialize do
    self.password = SecureRandom.hex(10)
  end

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i.freeze
  validates :email, presence: true, uniqueness: true, format: { with: VALID_EMAIL_REGEX }

  # membershipの更新をjobで予約して、その内容をmembership_logに記録
  def schedule_membership(params)
    job = self.delay(run_at: params[:apply_at], queue: 'membership')
              .upsert_membership(plan: params[:plan], status: params[:status])
    self.membership_logs.create(delayed_job_id: job.id, **params)
  end

  def upsert_membership(params)
    Membership.upsert(id: self.id, **params)
  end
end
