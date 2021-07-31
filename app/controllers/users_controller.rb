class UsersController < ApplicationController
  def destroy
    @user = User.find_by(email: params[:email])
    begin
      # 有料ユーザーのときは処理をスキップして手動削除
      if @user.stripe_customer_id
        logger.error "[Error] Paid account cancelled: #{@user.stripe_customer_id}"
      else
        @user.destroy
      end
      flash[:success] = '退会処理を完了しました。すべての課金とメール配信を停止します。これまでのご利用ありがとうございました。'
      redirect_to params[:redirect_to] || root_path
    rescue => e
      logger.error "[Error]Unsubscription failed: #{e.message}, #{current_user.id}"
      flash[:error] = '処理に失敗しました。。何回か試してもうまくいかない場合、お手数ですが運営までお問い合わせください。'
      redirect_to page_path(:unsubscribe)
    end
  end
end
