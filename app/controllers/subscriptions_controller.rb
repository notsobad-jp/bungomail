class SubscriptionsController < ApplicationController
  def create
    book_assignment = BookAssignment.find(params[:book_assignment_id])
    delivery_method = params[:delivery_method] == "email" && current_user.basic_plan? ? "email" : "webpush"

    Subscription.create!(
      book_assignment: book_assignment,
      delivery_method: delivery_method,
      user: current_user,
    )

    redirect_to book_assignment_path(book_assignment), flash: { success: '配信の購読が完了しました！' }
  rescue => e
    path = book_assignment ? book_assignment_path(book_assignment) : mypage_path
    redirect_to path, flash: { error: "購読処理に失敗しました。。" }
  end
end
