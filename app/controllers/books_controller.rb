class BooksController < ApplicationController
  def show
    @book = AozoraBook.find(params[:id])
    @book_assignment = BookAssignment.new(
      book_id: params[:id],
      book_type: 'AozoraBook',
      start_date: params[:start_date],
      end_date: params[:end_date],
      delivery_time: params[:delivery_time] || '07:00',
    )

    # 推奨配信期間
    if @book.words_count < 25000
      days = [@book.words_count.fdiv(750).ceil, 30].min
      @recommended_duration = "#{days}日"
    else
      @recommended_duration = "#{@book.words_count.fdiv(22500).ceil}ヶ月"
    end

    @meta_title = @book.title
    @breadcrumbs = [ {text: 'カスタム配信', link: page_path(:custom_delivery)}, {text: @meta_title} ]
  end
end
