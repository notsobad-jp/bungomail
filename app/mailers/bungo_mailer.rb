class BungoMailer < ApplicationMailer
  def customer_portal_email
    @user = params[:user]
    @url = params[:url]

    xsmtp_api_params = { category: 'customer_portal' }
    headers['X-SMTPAPI'] = JSON.generate(xsmtp_api_params)

    mail(to: @user.email, subject: "【ブンゴウメール】ご登録情報の確認用URL")
    logger.info "[CUSTOMER_PORTAL] email sent to #{@user.id}"
  end

  def feed_email
    @feed = params[:feed]
    @book = @feed.book_assignment.book
    @channel = @feed.book_assignment.channel
    @word_count = @feed.content.gsub(" ", "").length

    sender_name = envelope_display_name("#{@book.author_name}（ブンゴウメール）")
    send_to = params[:send_to] || @channel.active_subscribers.map(&:email)

    xsmtp_api_params = { to: send_to, category: 'feed' }
    headers['X-SMTPAPI'] = JSON.generate(xsmtp_api_params)

    mail(from: "#{sender_name} <bungomail@notsobad.jp>", subject: @feed.title)
    logger.info "[FEED] channel: #{@channel.code || @channel.id}, title: #{@feed.title}"
  end

  def marketing_email
    mail_to = "bungomail-text@notsobad.jp"
    xsmtp_api_params = { category: 'marketing' }
    headers['X-SMTPAPI'] = JSON.generate(xsmtp_api_params)

    mail(to: mail_to, subject: "【ブンゴウメール】無料配信終了のお知らせ & 優待キャンペーンは本日までです")
    logger.info "[Marketing] email sent to #{mail_to}"
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
    @ba = params[:book_assignment]
    xsmtp_api_params = { category: 'schedule_completed' }
    headers['X-SMTPAPI'] = JSON.generate(xsmtp_api_params)
    mail(to: @user.email, subject: "【ブンゴウメール】配信予約が完了しました")
  end

  def stripe_registered_email
    @user = params[:user]
    xsmtp_api_params = { category: 'stripe_registered' }
    headers['X-SMTPAPI'] = JSON.generate(xsmtp_api_params)
    mail(to: @user.email, subject: "【ブンゴウメール】お支払い情報の登録が完了しました")
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
