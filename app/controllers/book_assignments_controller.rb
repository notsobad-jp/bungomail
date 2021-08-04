class BookAssignmentsController < ApplicationController
  def create
    @user = User.find_by(email: ba_params[:email])
    raise '有料プランの登録が確認できませんでした。カスタム配信を利用する際は、事前にブンゴウメール有料プランへの登録が必要です' if !@user || !@user.stripe_customer_id

    @channel = Channel.find_or_create_by(user_id: @user.id)
    @book_assignment = @channel.book_assignments.new(
      book_id: ba_params[:book_id],
      book_type: ba_params[:book_type],
      start_date: ba_params[:start_date],
      end_date: ba_params[:end_date],
    )
    if @book_assignment.save
      @book_assignment.delay.create_and_schedule_feeds
      flash[:success] = '配信予約が完了しました！'
      # TODO: 予約完了メール送信
    else
      # TODO: validationエラーの処理
      flash[:error] = '登録失敗しました'
      logger.error 'エラー'
      render 'books/show'
    end
  rescue => e
    logger.error e
    flash[:error] = e
    redirect_to book_path(id: ba_params[:book_id], start_date: ba_params[:start_date], end_date: ba_params[:end_date])
  end

  private

  def ba_params
    params.require(:book_assignment).permit(:book_id, :book_type, :channel_id, :start_date, :end_date, :email)
  end
end
