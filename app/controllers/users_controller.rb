class UsersController < ApplicationController
  before_action :set_stripe_key
  before_action :require_login, only: [:show, :update, :webpush_test]

  def new
    redirect_to(mypage_path) if current_user

    @meta_title = 'アカウント登録'
    @no_index = true
  end

  def create
    user = User.find_or_initialize_by(email: user_params[:email])

    # すでに登録済みの場合はログイン画面へ
    if user.persisted?
      flash[:error] = 'このメールアドレスはすでに登録されています。登録情報を確認・更新したい場合はログインしてください。'
      redirect_to(login_path) and return
    end

    user.save
    user.generate_magic_login_token!

    BungoMailer.with(user: user).user_registered_email.deliver_later
    redirect_to(root_path, flash: { success: 'ユーザー登録が完了しました！ご登録内容の確認メールをお送りしています。もし10分以上経ってもメールが届かない場合は運営までお問い合わせください。' })
  end

  def show
    @meta_title = 'マイページ'
    @no_index = true

    # Customer PortalのURL取得
    if current_user.stripe_customer_id
      portal_session = Stripe::BillingPortal::Session.create(
        customer: current_user.stripe_customer_id,
        return_url: mypage_url,
      ) rescue nil
      @customer_portal_url = portal_session&.url
    end
  end

  # 今のところプッシュ通知の更新にしか使ってない
  def update
    current_user.update!(fcm_device_token: params[:token])
    head :ok
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

  def webpush_test
    body = {
      message: {
        token: current_user.fcm_device_token,
        title: "プッシュ通知テスト",
        body: "ブンゴウメールのプッシュ通知テスト配信です。",
        icon: "https://bungomail.com/favicon.ico",
        url: mypage_url,
      }
    }
    Webpush.call(body)
  rescue => e # ユーザーのwebpush設定をリセットしたりするのはJobのエラーハンドリングで対応してる
    p e
    flash[:error] = 'プッシュ通知のテスト送信に失敗しました。ブラウザの通知許可を再度ご設定ください。'
    redirect_to mypage_path
  end

  private

    def set_stripe_key
      Stripe.api_key = Rails.application.credentials.dig(:stripe, :secret_key)
    end

    def user_params
      params.require(:user).permit(:email)
    end
end
