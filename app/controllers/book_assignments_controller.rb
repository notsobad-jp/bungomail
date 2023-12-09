class BookAssignmentsController < ApplicationController
  before_action :require_login, only: [:index, :create, :destroy]
  after_action :verify_authorized, only: [:create, :destroy]

  def index
    @meta_title = "配信管理"

    if params[:finished].present?
      @book_assignments = BookAssignment.subscribed_by(current_user).finished.order(start_date: :desc).page(params[:page])
    else
      @book_assignments = BookAssignment.subscribed_by(current_user).upcoming.order(start_date: :desc).page(params[:page])
    end
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
    @subscription = current_user.subscriptions.find_by(book_assignment_id: @ba.id) if current_user
    @meta_title = @ba.book.author_and_book_name

    if @ba.user_id == current_user&.id
      @breadcrumbs = [ {text: "配信管理", link: book_assignments_path}, {text: @meta_title} ]
    else
      # 配信期間が重複している配信を取得
      @overlapping_assignments = BookAssignment.subscribed_by(current_user).where.not(id: @ba.id).overlapping_with(@ba.end_date, @ba.start_date)
    end
  end

  def destroy
    @ba = authorize BookAssignment.find(params[:id])
    @ba.destroy!
    BungoMailer.with(user: @ba.user, author_title: "#{@ba.book.author}『#{@ba.book.title}』", delivery_period: "#{@ba.start_date} 〜 #{@ba.end_date}").schedule_canceled_email.deliver_later
    flash[:success] = '配信を削除しました！'
    redirect_to book_assignments_path, status: 303
  end

  private

  def ba_params
    params.require(:book_assignment).permit(:book_id, :book_type, :start_date, :end_date, :delivery_time)
  end
end
