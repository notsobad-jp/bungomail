class UsersController < ApplicationController
  before_action :set_stripe_key

  def new
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

    # Stripe
    ## Customer作成
    customer = Stripe::Customer.create(email: user.email)

    ## SubscriptionSchedule作成
    Stripe::SubscriptionSchedule.create({
      customer: customer.id,
      start_date: "now",
      phases: [
        {
          # Freeプランをすぐに開始
          items: [
            { price: Rails.application.credentials.dig(:stripe, :plan_ids, :free) },
          ],
          end_date: Time.current.next_month.beginning_of_month.to_i,
        },
        {
          # 翌月初からBasicプランのトライアルを開始
          items: [
            { price: Rails.application.credentials.dig(:stripe, :plan_ids, :basic) },
          ],
          trial: true,
          end_date: Time.current.next_month.next_month.beginning_of_month.to_i,
        },
        {
          # 翌々月初から何もなければFreeプランに戻る
          items: [
            { price: Rails.application.credentials.dig(:stripe, :plan_ids, :free) },
          ],
          end_date: Time.current.next_month.next_month.beginning_of_month.to_i,
        },
      ],
    })

    # DBにデータ保存
    ActiveRecord::Base.transaction(joinable: false, requires_new: true) do
      user.update!(stripe_customer_id: customer.id)
      user.memberships.create!(plan: "free", trialing: false, apply_at: Date.current)
      user.memberships.create!(plan: "basic", trialing: true, apply_at: Date.current.next_month.beginning_of_month)
      user.memberships.create!(plan: "free", trialing: false, apply_at: Date.current.next_month.next_month.beginning_of_month)
    end


    BungoMailer.with(user: user).user_registered_email.deliver_later
    redirect_to(root_path, flash: { success: 'ユーザー登録が完了しました！ご登録内容の確認メールをお送りしています。もし10分以上経ってもメールが届かない場合は運営までお問い合わせください。' })
  rescue => e
    logger.error "[Error]Stripe subscription failed. #{e}"
    redirect_to(new_user_path, flash: { error: '決済処理に失敗しました。。課金処理を中止したため、これにより支払いが発生することはありません。解決しない場合は運営までお問い合わせください。' })
  end

  # Customer Portalの表示申請ページ
  def edit
    @meta_title = 'お支払い情報の管理'
    @no_index = true
  end

  # メアドを受け取ってCustomer PortalのURLをメール送信
  def update
    user = User.find_by(email: params[:email])
    if !user || !user.stripe_customer_id
      return redirect_to(edit_user_path, flash: { error: '入力されたメールアドレスで決済登録情報が確認できませんでした。解決しない場合は運営までお問い合わせください。' })
    end

    portal_session = Stripe::BillingPortal::Session.create(
      customer: user.stripe_customer_id,
      return_url: edit_user_url,
    )
    BungoMailer.with(user: user, url: portal_session.url).customer_portal_email.deliver_now

    redirect_to(edit_user_path, flash: { success: 'URLを送信しました。10分以上経過してもメールが届かない場合は運営までお問い合わせください' })
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
