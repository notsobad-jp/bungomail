class ChannelsController < ApplicationController
  after_action :authorize_record

  def index
    # 公開チャネルをcodeの指定順で表示
    codes = Channel::PUBLIC_CHANNEL_CODES
    @channels = Channel.where(code: codes).index_by(&:code).sort{|a, b| codes.index(a[0]) <=> codes.index(b[0]) }.to_h.values
    @meta_title = '公開チャネル'
  end

  def show
     # 公開チャネルはcodeでチャネル検索
    @channel = Channel::PUBLIC_CHANNEL_CODES.include?(params[:id]) ? Channel.find_by(code: params[:id]) : Channel.find(params[:id])
    @book_assignments = @channel.book_assignments.includes(:book).where("start_date < ?", Date.current).order(start_date: :desc).page(params[:page]).per 10
    @subscription = Subscription.find_by(user_id: current_user.id, channel_id: @channel.id) if current_user

    @meta_title = @channel.title || 'マイチャネル'
    @breadcrumbs = [
      # {text: '公開チャネル', link: channels_path},
      {text: @meta_title},
    ] if @channel.code.present?
  end

  def feed
     # 公開チャネルはcodeでチャネル検索
    @channel = Channel::PUBLIC_CHANNEL_CODES.include?(params[:id]) ? Channel.find_by(code: params[:id]) : Channel.find(params[:id])
    @feeds = Feed.delivered.where(book_assignment_id: @channel.book_assignments.pluck(:id)).order('feeds.delivery_date DESC').limit(30)
  end

  private

  def authorize_record
    authorize @channel || Channel
  end
end
