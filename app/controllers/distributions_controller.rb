class DistributionsController < ApplicationController
  before_action :require_login, only: [:index, :create, :destroy]
  after_action :verify_authorized, only: [:create, :destroy]

  def index
    @meta_title = "配信管理"

    if params[:finished].present?
      @distributions = Distribution.subscribed_by(current_user).finished.order(start_date: :desc).page(params[:page])
    else
      @distributions = Distribution.subscribed_by(current_user).upcoming.order(start_date: :desc).page(params[:page])
    end
  end

  def create
    authorize Distribution
    @distribution = current_user.distributions.new(ba_params)

    if @distribution.save
      sub = current_user.subscribe(@distribution, delivery_method: params[:delivery_method])
      if sub.delivery_method == "プッシュ通知" && current_user.fcm_device_token.present?
        Webpush.subscribe_to_topic!(
          token: current_user.fcm_device_token,
          topic: @distribution.id
        )
      end
      BungoMailer.with(user: current_user, distribution: @distribution).schedule_completed_email.deliver_later
      @distribution.delay.create_and_schedule_feeds
      flash[:success] = '配信予約が完了しました！予約内容をメールでお送りしていますのでご確認ください。'
      redirect_to distribution_path(@distribution)
    else
      @book = @distribution.book
      @meta_title = @book.title
      @breadcrumbs = [ {text: 'カスタム配信', link: page_path(:custom_delivery)}, {text: @meta_title} ]

      flash.now[:error] = @distribution.errors.full_messages.join('. ')
      render template: 'books/show', status: 422
    end
  end

  def show
    @distribution = Distribution.find(params[:id])
    @feeds = Feed.delivered.where(distribution_id: @distribution.id).order(delivery_date: :desc).page(params[:page]) # FIXME
    @subscription = current_user.subscriptions.find_by(distribution_id: @distribution.id) if current_user
    @meta_title = @distribution.book.author_and_book_name
    @breadcrumbs = [ {text: "配信管理", link: distributions_path}, {text: @meta_title} ] if current_user

    # 配信期間が重複している配信が存在してるかチェック
    if current_user && current_user.id != @distribution.user_id
      @overlapping_distributions = Distribution.subscribed_by(current_user).where.not(id: @distribution.id).overlapping_with(@distribution.end_date, @distribution.start_date)
    end
  end

  def destroy
    @distribution = authorize Distribution.find(params[:id])
    @distribution.destroy!
    if current_user.fcm_device_token.present?
      Webpush.unsubscribe_from_topic!(
        token: current_user.fcm_device_token,
        topic: @distribution.id
      )
    end
    BungoMailer.with(user: @distribution.user, author_title: "#{@distribution.book.author}『#{@distribution.book.title}』", delivery_period: "#{@distribution.start_date} 〜 #{@distribution.end_date}").schedule_canceled_email.deliver_later
    flash[:success] = '配信を削除しました！'
    redirect_to distributions_path, status: 303
  end

  private

  def ba_params
    params.require(:distribution).permit(:book_id, :book_type, :start_date, :end_date, :delivery_time)
  end
end
