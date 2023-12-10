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
      current_user.subscribe(@distribution, delivery_method: params[:delivery_method])
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
    @ba = Distribution.find(params[:id])
    @feeds = Feed.delivered.where(distribution_id: @ba.id).order(delivery_date: :desc).page(params[:page]) # FIXME
    @subscription = current_user.subscriptions.find_by(distribution_id: @ba.id) if current_user
    @meta_title = @ba.book.author_and_book_name
    @breadcrumbs = [ {text: "配信管理", link: distributions_path}, {text: @meta_title} ] if current_user

    # 配信期間が重複している配信が存在してるかチェック
    if current_user && current_user.id != @ba.user_id
      @overlapping_assignments = Distribution.subscribed_by(current_user).where.not(id: @ba.id).overlapping_with(@ba.end_date, @ba.start_date)
    end
  end

  def destroy
    @ba = authorize Distribution.find(params[:id])
    @ba.destroy!
    BungoMailer.with(user: @ba.user, author_title: "#{@ba.book.author}『#{@ba.book.title}』", delivery_period: "#{@ba.start_date} 〜 #{@ba.end_date}").schedule_canceled_email.deliver_later
    flash[:success] = '配信を削除しました！'
    redirect_to distributions_path, status: 303
  end

  private

  def ba_params
    params.require(:distribution).permit(:book_id, :book_type, :start_date, :end_date, :delivery_time)
  end
end
