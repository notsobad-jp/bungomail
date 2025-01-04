class BungoMailer < ApplicationMailer
  def feed_email
    @campaign = params[:campaign]
    @content = params[:content]
    @index = params[:index]
    send_to = params[:send_to] || @campaign.send_to
    return if send_to.blank?

    @word_count = @content.gsub(" ", "").length
    sender_name = envelope_display_name("#{@campaign.author_name}（ブンゴウメール）")

    xsmtp_api_params = { to: send_to, category: 'feed' }
    headers['X-SMTPAPI'] = JSON.generate(xsmtp_api_params)

    mail(from: "#{sender_name} <bungomail@notsobad.jp>", subject: @campaign.title)
  end

  def magic_login_email
    user = params[:user]
    @url  = URI.join(root_url, "/auth?token=#{user.magic_login_token}")
    @token = user.magic_login_token

    xsmtp_api_params = { category: 'login' }
    headers['X-SMTPAPI'] = JSON.generate(xsmtp_api_params)
    mail(to: user.email, subject: '【ブンゴウメール】ログイン用URL')
  end

  def schedule_canceled_email
    @user = params[:user]
    @author_title = params[:author_title]
    @delivery_period = params[:delivery_period]
    xsmtp_api_params = { category: 'schedule_canceled' }
    headers['X-SMTPAPI'] = JSON.generate(xsmtp_api_params)
    mail(to: @user.email, subject: "【ブンゴウメール】配信予約をキャンセルしました")
  end

  def schedule_completed_email
    @user = params[:user]
    @campaign = params[:campaign]
    xsmtp_api_params = { category: 'schedule_completed' }
    headers['X-SMTPAPI'] = JSON.generate(xsmtp_api_params)
    mail(to: @user.email, subject: "【ブンゴウメール】配信予約が完了しました")
  end

  def user_registered_email
    @user = params[:user]
    @url  = URI.join(root_url, "/auth?token=#{@user.magic_login_token}")

    xsmtp_api_params = { category: 'user_registered' }
    headers['X-SMTPAPI'] = JSON.generate(xsmtp_api_params)
    mail(to: @user.email, subject: "【ブンゴウメール】ユーザー登録が完了しました")
  end

  def webpush_failed_email
    @user = params[:user]
    xsmtp_api_params = { category: 'webpush_failed' }
    headers['X-SMTPAPI'] = JSON.generate(xsmtp_api_params)
    mail(to: @user.email, subject: "【ブンゴウメール】プッシュ通知の送信に失敗しました")
  end


  private

  # メール送信名をRFCに準拠した形にフォーマット
  ## http://kotaroito.hatenablog.com/entry/2016/09/23/103436
  def envelope_display_name(display_name)
    name = display_name.dup

    # Special characters
    if name && name =~ /[\(\)<>\[\]:;@\\,\."]/
      # escape double-quote and backslash
      name.gsub!(/\\/, '\\')
      name.gsub!(/"/, '\"')

      # enclose
      name = '"' + name + '"'
    end

    name
  end
end
