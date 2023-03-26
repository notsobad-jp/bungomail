class MagicTokensController < ApplicationController
  before_action :require_login, only: [:destroy]

  def new
    redirect_to mypage_path if current_user
    @meta_title = 'ログイン'
  end

  def create
    @user = User.find_by(email: params[:email])
    return redirect_to login_path, flash: { error: 'メールアドレスが見つかりませんでした。。初めての方はアカウント登録してください。' } unless @user

    @user.generate_magic_login_token!
    BungoMailer.with(user: @user).magic_login_email.deliver_later
    flash[:success] = 'ログイン用URLを送信しました！メールに記載されたURLからログインしてください。'
    redirect_to login_path
  end

  def auth
    @token = params[:token]
    @user = User.load_from_magic_login_token(params[:token])
    return not_authenticated if @user.blank?

    auto_login(@user)
    flash[:success] = 'ログインしました！'
    redirect_to mypage_path
  end

  def destroy
    logout
    flash[:info] = 'ログアウトしました'
    redirect_to root_path
  end
end
