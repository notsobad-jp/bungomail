class BookAssignmentsController < ApplicationController
  def create
    @user = User.find_by(email: ba_params[:email])
    raise "有料プランの登録が確認できませんでした。カスタム配信を利用する際は、事前に#{view_context.link_to 'ブンゴウメール有料プランへの登録', memberships_new_path, class: 'text-link'}が必要です。" if !@user || !@user.stripe_customer_id

    @channel = Channel.where(id: @user.id, user_id: @user.id).first_or_create
    @ba = @channel.book_assignments.create!(
      book_id: ba_params[:book_id],
      book_type: ba_params[:book_type],
      start_date: ba_params[:start_date],
      end_date: ba_params[:end_date],
    )
    @ba.delay.create_and_schedule_feeds
    BungoMailer.with(user: @user, book_assignment: @ba).schedule_completed_email.deliver_later
    flash[:success] = '配信予約が完了しました！予約内容をメールでお送りしていますのでご確認ください。'
    redirect_to book_path(ba_params[:book_id])
  rescue => e
    logger.error e
    flash[:error] = e
    redirect_to book_path(id: ba_params[:book_id], start_date: ba_params[:start_date], end_date: ba_params[:end_date])
  end

  def cancel
    @ba = BookAssignment.find_by(id: params[:id])
    raise '【エラー】配信が見つかりませんでした。。解決しない場合は運営までお問い合わせください。' if !@ba
    @ba.destroy!
    BungoMailer.with(user: @ba.channel.user, author_title: "#{@ba.book.author}『#{@ba.book.title}』", delivery_period: "#{@ba.start_date} 〜 #{@ba.end_date}").schedule_canceled_email.deliver_later
    flash[:success] = '配信をキャンセルしました！'
    redirect_to page_path(:book_assignment_canceled)
  rescue => e
    logger.error e
    flash[:error] = e
    redirect_to root_path
  end

  private

  def ba_params
    params.require(:book_assignment).permit(:book_id, :book_type, :channel_id, :start_date, :end_date, :email)
  end
end
