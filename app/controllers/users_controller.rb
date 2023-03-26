class UsersController < ApplicationController
  before_action :set_stripe_key
  before_action :require_login, only: [:show]

  def new
    redirect_to(mypage_path) if current_user

    @meta_title = '新規ユーザー登録'
    @no_index = true
  end

  def create
    user = User.find_or_initialize_by(email: user_params[:email])

    # customerが過去にstripe登録済み（重複登録 or 退会→再登録）の場合はとりあえず手動対応
    if user.stripe_customer_id.present?
      flash[:error] = 'このメールアドレスはすでに登録されています。登録情報を確認・更新したい場合は「利用者メニュー」をご利用ください。'
      redirect_to(new_user_path) and return
    end

    # StripeにCustomer作成
    customer = Stripe::Customer.create(email: user.email)

    # DBにユーザー登録（翌月初からトライアル開始）
    user.update!(
      stripe_customer_id: customer.id,
      trial_start_date: Date.current.next_month.beginning_of_month,
      trial_end_date: Date.current.next_month.end_of_month,
    )

    # StripeにSucscription作成
    ## CustomerPortalを使えるようにするため、Stripe上はこの時点からトライアル扱い（実際の配信はまだしない）
    beginning_of_next_next_month = Time.current.next_month.next_month.beginning_of_month
    Stripe::Subscription.create({
      customer: customer.id,
      default_tax_rates: [ Rails.application.credentials.dig(:stripe, :tax_rate_id) ],
      trial_end: beginning_of_next_next_month.to_i,
      items: [
        {price: Rails.application.credentials.dig(:stripe, :plan_id) }
      ],
    })

    BungoMailer.with(user: user).user_registered_email.deliver_later
    redirect_to(root_path, flash: { success: 'ユーザー登録が完了しました！ご登録内容の確認メールをお送りしています。もし10分以上経ってもメールが届かない場合は運営までお問い合わせください。' })
  rescue => e
    logger.error "[Error]Stripe subscription failed. #{e}"
    redirect_to(new_user_path, flash: { error: '決済処理に失敗しました。。課金処理を中止したため、これにより支払いが発生することはありません。解決しない場合は運営までお問い合わせください。' })
  end

  def show
    @meta_title = 'マイページ'
    @no_index = true

    @upcoming_assignments = current_user.book_assignments.upcoming.order(:start_date)

    # Customer PortalのURL取得
    if current_user.stripe_customer_id
      portal_session = Stripe::BillingPortal::Session.create(
        customer: current_user.stripe_customer_id,
        return_url: mypage_url,
      ) rescue nil
      @customer_portal_url = portal_session&.url
    end
  end

  def destroy
    begin
      @user = User.find_by(email: params[:email])
      if @user.blank?
        flash[:error] = '入力されたメールアドレスで登録が確認できませんでした。入力内容をご確認いただき、それでも解決しない場合はお手数ですが運営までお問い合わせください。'
        redirect_to page_path(:unsubscribe) and return
      end

      # 有料ユーザーのときは処理をスキップして手動削除
      if @user.stripe_customer_id # paid_memberで判定すると、トライアル前の人も削除してstripeだけに残っちゃうので広く拾う
        logger.error "[Error] Paid account cancelled: #{@user.stripe_customer_id}"
      else
        @user.destroy
      end
      flash[:success] = '退会処理を完了しました。すべての課金とメール配信を停止します。これまでのご利用ありがとうございました。'
      redirect_to params[:redirect_to] || root_path
    rescue => e
      logger.error "[Error]Unsubscription failed: #{e.message}, #{params[:email]}"
      flash[:error] = '処理に失敗しました。。何回か試してもうまくいかない場合、お手数ですが運営までお問い合わせください。'
      redirect_to page_path(:unsubscribe)
    end
  end

  private

    def set_stripe_key
      Stripe.api_key = Rails.application.credentials.dig(:stripe, :secret_key)
    end

    def user_params
      params.require(:user).permit(:email)
    end
end
