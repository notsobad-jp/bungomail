class CampaignsController < ApplicationController
  before_action :require_login, only: [:index, :create, :destroy]
  after_action :verify_authorized, only: [:create, :destroy]

  def index
  end

  def create
    campaign = current_user.campaigns.new(campaign_params)
    if campaign.create_and_subscribe
      BungoMailer.with(user: current_user, campaign: campaign).schedule_completed_email.deliver_now
      flash[:success] = '配信予約が完了しました！予約内容をメールでお送りしていますのでご確認ください。'
      redirect_to campaign_path(campaign)
    else
      @book = campaign.book
      @meta_title = @book.title

      flash.now[:error] = campaign.errors.full_messages.join('. ')
      render template: 'books/show', status: 422
    end
  end

  def show
    @campaign = Campaign.find(params[:id])
    @feeds = Feed.delivered.where(campaign_id: @campaign.id).order(delivery_date: :desc).page(params[:page]) # FIXME
    @subscription = current_user.subscriptions.find_by(campaign_id: @campaign.id) if current_user
    @meta_title = @campaign.author_and_book_name

    # 配信期間が重複している配信が存在してるかチェック
    if current_user && current_user.id != @campaign.user_id
      @overlapping_campaigns = Campaign.subscribed_by(current_user).where.not(id: @campaign.id).overlapping_with(@campaign.end_date, @campaign.start_date)
    end
  end

  def destroy
    @campaign = authorize Campaign.find(params[:id])
    @campaign.destroy!
    if current_user.fcm_device_token.present?
      Webpush.unsubscribe_from_topic!(
        token: current_user.fcm_device_token,
        topic: @campaign.id
      )
    end
    BungoMailer.with(user: @campaign.user, author_title: @campaign.author_and_book_name, delivery_period: "#{@campaign.start_date} 〜 #{@campaign.end_date}").schedule_canceled_email.deliver_now
    flash[:success] = '配信を削除しました！'
    redirect_to campaigns_path, status: 303
  end

  private

  def campaign_params
    params.require(:campaign).permit(
      :book_id,
      :book_type,
      :title,
      :file_id,
      :author_name,
      :start_date,
      :end_date,
      :delivery_time,
      :color,
      :pattern,
      :delivery_method,
    )
  end
end
