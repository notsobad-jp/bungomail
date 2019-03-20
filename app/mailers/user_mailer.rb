class UserMailer < ApplicationMailer
  add_template_helper(ApplicationHelper)

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.magic_login_email.subject
  #
  def magic_login_email(user)
    @user = User.find user.id
    @url  = URI.join(root_url, "auth?token=#{@user.magic_login_token}")

    xsmtp_api_params = { category: 'login' }
    headers['X-SMTPAPI'] = JSON.generate(xsmtp_api_params)

    mail(to: @user.email, subject: '【ブンゴウメール】ログイン用URL')
    logger.info "[LOGIN] Login mail sent to #{@user.id}"
  end

  def chapter_email
    @subscription = params[:subscription]
    @notification = Notification.find_by(date: Time.current)
    @comment = @subscription.current_comment
    send_at = Time.zone.parse(@subscription.next_delivery_date.to_s).change(hour: @subscription.delivery_hour)

    # 実際の配信先（PROプランのユーザー）がいない場合は処理をスキップ
    return if (deliverable_emails = @subscription.deliverable_emails).blank?

    xsmtp_api_params = {
      send_at: send_at.to_i,
      to: deliverable_emails,
      category: 'chapter'
    }
    headers['X-SMTPAPI'] = JSON.generate(xsmtp_api_params)

    # HACK: ALTER EGOチャネルのみ独自の配信元表記。そのうち汎用化する
    # TODO: 検証用にブンゴウメールチャネルの配信元を一時変更
    if @subscription.channel.user_id == User::ALTEREGO_ID || @subscription.channel_id == Channel::BUNGOMAIL_ID
      from_name = 'エス（ALTER EGO）'
      from_email = 'alterego@notsobad.jp'
      subject = "#{@subscription.current_book.author.tr(',', '、')}『#{@subscription.current_book.title}』（#{@subscription.next_chapter.index}/#{@subscription.current_book.chapters_count}） - #{@subscription.channel.title}"
    else
      from_name = "#{@subscription.current_book.author.tr(',', '、')}（ブンゴウメール）"
      from_email = 'bungomail@notsobad.jp'
      subject = "#{@subscription.current_book.title}（#{@subscription.next_chapter.index}/#{@subscription.current_book.chapters_count}） - #{@subscription.channel.title}"
    end


    mail(
      from: "#{from_name} <#{from_email}>",
      to: 'noreply@notsobad.jp', # xsmtpパラメータで上書きされるのでこのtoはダミー
      subject: subject,
      reply_to: 'info@notsobad.jp'
    ) do |format|
      format.text
      format.html if @subscription.channel.id != Channel::BUNGOMAIL_ID # 旧ブンゴウメール公式チャネルはGoogleGroupsへの配信なので、テキストメールのみ
    end
    logger.info "[SCHEDULED] channel:#{@subscription.channel.id}, chapter:#{@subscription.next_chapter.book_id}-#{@subscription.next_chapter.index}, send_at:#{send_at}, to:#{@subscription.user_id}"
  end
end
