class BookAssignmentsController < ApplicationController
  before_action :require_login, only: [:create]

  # 公式チャネルの過去配信一覧
  def index
    year = params[:year] || Time.current.year
    start = Time.current.change(year: year).beginning_of_year
    @book_assignments = BookAssignment.includes(:book).where(user_id: User.find_by(email: 'info@notsobad.jp'), start_date: start..start.end_of_year).where("start_date < ?", Time.zone.today).order(:start_date)
    @meta_title = "過去配信作品（#{year}）"
  end

  def create
    ActiveRecord::Base.transaction(joinable: false, requires_new: true) do
      @ba = current_user.book_assignments.create!(ba_params)
      current_user.subscribe(@ba, delivery_method: params[:delivery_method])
    end

    BungoMailer.with(user: current_user, book_assignment: @ba).schedule_completed_email.deliver_later
    @ba.delay.create_and_schedule_feeds
    flash[:success] = '配信予約が完了しました！予約内容をメールでお送りしていますのでご確認ください。'
    redirect_to book_assignment_path(@ba)
  rescue => e
    logger.error e if ![ActiveRecord::RecordNotFound, ActiveRecord::RecordInvalid].include?(e.class)
    flash[:error] = e
    redirect_to book_path(id: ba_params[:book_id], start_date: ba_params[:start_date], end_date: ba_params[:end_date], delivery_time: ba_params[:delivery_time])
  end

  def show
    @ba = BookAssignment.find(params[:id])
    @feeds = Feed.delivered.where(book_assignment_id: @ba.id).order(delivery_date: :desc).page(params[:page]) # FIXME
    @meta_title = @ba.book.author_and_book_name
  end

  def destroy
    @ba = BookAssignment.find(params[:id])
    @ba.destroy!
    BungoMailer.with(user: @ba.user, author_title: "#{@ba.book.author}『#{@ba.book.title}』", delivery_period: "#{@ba.start_date} 〜 #{@ba.end_date}").schedule_canceled_email.deliver_later
    flash[:success] = '配信を削除しました！'
    redirect_to mypage_path, status: 303
  rescue => e
    logger.error e if e.class != ActiveRecord::RecordNotFound
    flash[:error] = e
    redirect_to root_path
  end

  private

  def ba_params
    params.require(:book_assignment).permit(:book_id, :book_type, :start_date, :end_date, :delivery_time)
  end
end
