class User < ApplicationRecord
  authenticates_with_sorcery!

  has_many :distributions, dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  scope :activated_in_stripe, -> (active_emails) { where(plan: :free).where(email: active_emails) }  # stripeで購読したけどまだDBの支払いステータスに反映されていないuser
  scope :canceled_in_stripe, -> (active_emails) { where(plan: :basic).where.not(email: active_emails) }  # stripeで解約したけどまだDBの支払いステータスに反映されていないuser

  enum plan: { free_plan: "free", basic_plan: "basic" }

  validates :email, presence: true, uniqueness: true

  # activation実行に必要なのでダミーのパスワードを設定
  ## before_validateでcryptedの作成処理が走るので、それより先に用意できるようにafter_initializeを使用
  after_initialize do
    self.password = SecureRandom.hex(10)
  end

  # 新規作成時（未activation）: EmailDigest作成
  after_create do
    EmailDigest.find_or_create_by!(digest: digest) # 退会済みユーザーの場合はEmailDigestが存在する
  end

  # Email変更後にEmailDigestも変更
  after_update do
    if saved_change_to_email?
      ed = EmailDigest.find_by(digest: Digest::SHA256.hexdigest(email_before_last_save))
      ed.update(digest: digest)
    end
  end

  after_destroy do
    EmailDigest.find_by(digest: digest).update(canceled_at: Time.current)
  end

  def admin?
    email == "info@notsobad.jp"
  end

  def digest
    Digest::SHA256.hexdigest(email)
  end

  def subscribe(distribution, delivery_method: "email")
    subscriptions.create!(distribution: distribution, delivery_method: delivery_method)
  end

  def trialing?
    trial_start_date && trial_start_date <= Date.current && Date.current <= trial_end_date
  end

  def trial_scheduled?
    trial_start_date && Date.current <= trial_start_date
  end

  class << self
    # stripeで支払い中のメールアドレス一覧
    def active_emails_in_stripe
      emails = []
      subscriptions = Stripe::Subscription.list({limit: 100, expand: ['data.customer']})
      subscriptions.auto_paging_each do |sub|
        emails << sub.customer.email
      end
      raise 'Email duplicated!' if emails.length != emails.uniq.length
      emails
    end
  end
end
