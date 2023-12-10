class PagesController < ApplicationController
  def lp
    @meta_title = 'ブンゴウメール | 1日3分のメールでムリせず毎月1冊本が読める、忙しいあなたのための読書サポートサービス'
    @meta_description = '青空文庫の作品を小分けにして、毎朝メールで配信。気づいたら毎月1冊本が読めてしまう、忙しいあなたのための読書サポートサービスです。'
  end

  def show
    @meta_title = page_titles[params[:page].to_sym]
    raise ActionController::RoutingError, request.url unless @meta_title
    @meta_description = @meta_title
    render params[:page]
  end

  def dogramagra
    @meta_title = "ドグラ・マグラ365日配信チャレンジ"
    @meta_description = "夢野久作『ドグラ・マグラ』を、365日かけて毎日メールで少しずつ配信します。"
    @meta_image = "https://bungomail.com/assets/images/campaigns/dogramagra.png"
  end

  def past_deliveries
    year = params[:year] || Time.current.year
    start = Time.current.change(year: year).beginning_of_year
    @distributions = Distribution.includes(:book).where(user_id: User.find_by(email: 'info@notsobad.jp'), start_date: start..start.end_of_year).where("start_date < ?", Time.zone.today).order(:start_date)
    @meta_title = "過去配信作品（#{year}）"
  end

  private

  def page_titles
    {
      terms: '利用規約',
      privacy: 'プライバシーポリシー',
      tokushoho: '特定商取引法に基づく表記',
      unsubscribe: '退会',
      custom_delivery: 'カスタム配信',
    }
  end
end
