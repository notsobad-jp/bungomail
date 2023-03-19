class BookAssignmentsController < ApplicationController
  def create
    # 有料会員（トライアル含む）or トライアル開始前（予約済み）の人が配信予約可能
    @user = User.where(email: ba_params[:email]).merge(
      User.basic_plan.or(User.where("trial_start_date >= ?", Date.current))
    ).first
    raise ActiveRecord::RecordNotFound.new("有料プランの登録が確認できませんでした。カスタム配信を利用する際は、事前に#{view_context.link_to 'ブンゴウメール有料プランへの登録', new_user_path, class: 'text-link'}が必要です。") if !@user

    @ba = @user.book_assignments.create!(
      book_id: ba_params[:book_id],
      book_type: ba_params[:book_type],
      start_date: ba_params[:start_date],
      end_date: ba_params[:end_date],
      delivery_time: ba_params[:delivery_time],
    )
    BungoMailer.with(user: @user, book_assignment: @ba).schedule_completed_email.deliver_later
    @ba.delay.create_and_schedule_feeds
    flash[:success] = '配信予約が完了しました！予約内容をメールでお送りしていますのでご確認ください。'
    redirect_to book_path(ba_params[:book_id])
  rescue => e
    logger.error e if ![ActiveRecord::RecordNotFound, ActiveRecord::RecordInvalid].include?(e.class)
    flash[:error] = e
    redirect_to book_path(id: ba_params[:book_id], start_date: ba_params[:start_date], end_date: ba_params[:end_date], delivery_time: ba_params[:delivery_time])
  end

  def cancel
    @ba = BookAssignment.find_by(id: params[:id])
    raise ActiveRecord::RecordNotFound.new('【エラー】配信が見つかりませんでした。。解決しない場合は運営までお問い合わせください。') if !@ba || @ba.user.email == "info@notsobad.jp"
    @meta_title = '配信停止'
    @breadcrumbs = [ {text: 'カスタム配信', link: page_path(:custom_delivery)}, {text: @meta_title} ]
  rescue => e
    logger.error e if e.class != ActiveRecord::RecordNotFound
    flash[:error] = e
    redirect_to root_path
  end

  def destroy
    @ba = BookAssignment.find_by(id: params[:id])
    raise ActiveRecord::RecordNotFound.new('【エラー】配信が見つかりませんでした。。解決しない場合は運営までお問い合わせください。') if !@ba || @ba.user.email == "info@notsobad.jp"
    @ba.destroy!
    BungoMailer.with(user: @ba.user, author_title: "#{@ba.book.author}『#{@ba.book.title}』", delivery_period: "#{@ba.start_date} 〜 #{@ba.end_date}").schedule_canceled_email.deliver_later
    flash[:success] = '配信をキャンセルしました！'
    redirect_to page_path(:book_assignment_canceled)
  rescue => e
    logger.error e if e.class != ActiveRecord::RecordNotFound
    flash[:error] = e
    redirect_to root_path
  end

  private

  def ba_params
    params.require(:book_assignment).permit(:book_id, :book_type, :user_id, :start_date, :end_date, :email, :delivery_time)
  end
end
