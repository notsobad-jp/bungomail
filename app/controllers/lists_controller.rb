class ListsController < ApplicationController
  def books
    year = params[:year] || Time.current.year
    start = Time.current.change(year: year).beginning_of_year
    @book_assignments = BookAssignment.includes(:book).where(channel_id: Channel.find_by(code: 'bungomail-official'), start_date: start..start.end_of_year).where("start_date < ?", Time.zone.today).order(:start_date)
    @meta_title = "過去配信作品（#{year}）"
  end
end
