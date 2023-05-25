class BookAssignmentsController < ApplicationController
  before_action :require_login, only: [:create, :destroy]
  after_action :verify_authorized, only: [:create, :destroy]

  # 公式チャネルの過去配信一覧
  def index
    year = params[:year] || Time.current.year
    start = Time.current.change(year: year).beginning_of_year
    @book_assignments = BookAssignment.includes(:book).where(user_id: User.find_by(email: 'info@notsobad.jp'), start_date: start..start.end_of_year).where("start_date < ?", Time.zone.today).order(:start_date)
    @meta_title = "過去配信作品（#{year}）"
  end

  def create
    authorize BookAssignment
    @book_assignment = current_user.book_assignments.new(ba_params)

    if @book_assignment.save
      current_user.subscribe(@book_assignment, delivery_method: params[:delivery_method])
      BungoMailer.with(user: current_user, book_assignment: @book_assignment).schedule_completed_email.deliver_later
      @book_assignment.delay.create_and_schedule_feeds
      flash[:success] = '配信予約が完了しました！予約内容をメールでお送りしていますのでご確認ください。'
      redirect_to book_assignment_path(@book_assignment)
    else
      @book = @book_assignment.book
      @meta_title = @book.title
      @breadcrumbs = [ {text: 'カスタム配信', link: page_path(:custom_delivery)}, {text: @meta_title} ]

      flash.now[:error] = @book_assignment.errors.full_messages.join('. ')
      render template: 'books/show', status: 422
    end
  end

  def show
    @ba = BookAssignment.find(params[:id])
    @feeds = Feed.delivered.where(book_assignment_id: @ba.id).order(delivery_date: :desc).page(params[:page]) # FIXME
    @meta_title = @ba.book.author_and_book_name
  end

  def destroy
    @ba = BookAssignment.find(params[:id])
    authorize @ba
    @ba.destroy!
    BungoMailer.with(user: @ba.user, author_title: "#{@ba.book.author}『#{@ba.book.title}』", delivery_period: "#{@ba.start_date} 〜 #{@ba.end_date}").schedule_canceled_email.deliver_later
    flash[:success] = '配信を削除しました！'
    redirect_to mypage_path, status: 303
  end

  private

  def ba_params
    params.require(:book_assignment).permit(:book_id, :book_type, :start_date, :end_date, :delivery_time)
  end
end
