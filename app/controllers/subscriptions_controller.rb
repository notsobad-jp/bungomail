class SubscriptionsController < ApplicationController
  before_action :require_login, only: [:create, :destroy]

  def create
    book_assignment = BookAssignment.find(params[:book_assignment_id])
    delivery_method = params[:delivery_method] == "email" && current_user.basic_plan? ? "email" : "webpush"

    Subscription.create!(
      book_assignment: book_assignment,
      delivery_method: delivery_method,
      user: current_user,
    )

    redirect_to book_assignment_path(book_assignment), flash: { success: '配信の購読が完了しました！' }
  end

  def destroy
    subscription = Subscription.find(params[:id])
    subscription.destroy!
    redirect_to book_assignment_path(subscription.book_assignment), flash: { success: "配信の購読を解除しました。" }, status: 303
  end
end
