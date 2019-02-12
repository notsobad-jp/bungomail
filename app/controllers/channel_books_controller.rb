class ChannelBooksController < ApplicationController
  before_action :require_login
  before_action :set_channel
  after_action :verify_authorized

  def create
    book = Book.find(params[:book_id])

    if @channel.add_book(book)
      channel_link = view_context.link_to @channel.title, channel_path(@channel)
      flash[:success] = "「#{channel_link}」に『#{book.title}』を追加しました🎉"
    else
      flash[:error] = '本の追加に失敗しました。。解決しない場合は運営までお問い合わせください。'
    end
    redirect_to params[:redirect_to]
  end

  private

  def set_channel
    @channel = Channel.includes(:channel_books).find(params[:id])
    authorize @channel, :update?
  end
end
