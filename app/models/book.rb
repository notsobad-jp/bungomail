class Book
  include ActiveModel::Model
  include ActiveModel::Attributes

  API_BASE_URL = "http://host.docker.internal:8787"
  PER_PAGE = 50

  # アクセス数に対する評価(PV数)
  ## ratingは JSON-LDで表示するメタ評価
  ## starsはサイト上で表示する星の数
  ACCESS_RATINGS = {
    20000 => { rating: 5,   stars: 3 },
    4000 =>   { rating: 4.5, stars: 2 },
    1 =>     { rating: 4,   stars: 1 },
    0 =>     { rating: 3,   stars: 0 }
  }.freeze

  CATEGORIES = {
    all: {
      id: 'all',
      name: 'すべて',
      range_from: 1,
      range_to: 9999999,
    },
    flash: {
      id: 'flash',
      name: '5分以内',
      title: '短編',
      range_from: 1,
      range_to: 2000,
    },
    shortshort: {
      id: 'shortshort',
      name: '10分以内',
      title: '短編',
      range_from: 2001,
      range_to: 4000,
    },
    short: {
      id: 'short',
      name: '30分以内',
      title: '短編',
      range_from: 4001,
      range_to: 12000,
    },
    novelette: {
      id: 'novelette',
      name: '60分以内',
      title: '中編',
      range_from: 12001,
      range_to: 24000,
    },
    novel: {
      id: 'novel',
      name: '1時間〜',
      title: '長編',
      range_from: 24001,
      range_to: 9999999,
    }
  }.freeze

  attribute :id, :integer
  attribute :title, :string
  attribute :titleKana, :string
  attribute :subTitle, :string
  attribute :subTitleKana, :string
  attribute :characterType, :string
  attribute :rightsReserved, :boolean, default: false
  attribute :accessCount, :integer, default: 0
  attribute :wordsCount, :integer, default: 0
  attribute :beginning, :string
  attribute :juvenile, :boolean, default: false
  attribute :author
  attribute :publishedDate, :date
  attribute :firstAppearance, :string
  attribute :source, :string
  attribute :variants
  attribute :fileId, :integer


  def access_rating
    ACCESS_RATINGS.find{|k,v| self.accessCount >= k }.dig(1, :rating)
  end

  def category
    return nil if wordsCount.nil?

    CATEGORIES.each do |key, config|
      next if key == :all
      if (config[:range_from]..config[:range_to]).include?(wordsCount)
        return config
      end
    end
    nil
  end

  def recommended_duration
    if wordsCount < 25000
      days = [wordsCount.fdiv(750).ceil, 30].min
      "#{days}日"
    else
      "#{wordsCount.fdiv(22500).ceil}ヶ月"
    end
  end

  class << self
    def where(keyword: nil, category: :all, page: 1)
      params = {}
      params[:q] = keyword if keyword.present?
      if category_config = CATEGORIES[category]
        params["words_count[gte]"] = category_config[:range_from]
        params["words_count[lte]"] = category_config[:range_to]
      end

      offset = (page - 1) * PER_PAGE

      params.merge!(
        sort: "access_count",
        limit: PER_PAGE,
        offset: offset
      )

      res = self.call(
        path: "/v1/books",
        params: params,
      )

      res["books"] = res["books"].map do |record|
        Book.new(record)
      end

      res
    end

    def find(id)
      res = self.call(path: "/v1/books/#{id.to_s}")
      Book.new(res)
    end
  end

  private

  class << self
    # 汎用APIcall
    def call(method: :get, path: "", params: nil)
      uri = URI.join(API_BASE_URL, path)
      p uri
      http = Net::HTTP.new(uri.host, uri.port)

      # GETパラメータをURIに設定
      uri.query = URI.encode_www_form(params) if params && method == :get

      # パスとクエリを含むフルパスを使用
      req = Net::HTTP.const_get(method.to_s.capitalize).new(
        [uri.path, uri.query].compact.join('?')
      )
      req["content-type"] = 'application/json'

      # GETの場合はbodyにパラメータを設定しない
      req.body = params.to_json if params && method != :get

      res = (body = http.request(req).body.presence) ? JSON.parse(body) : nil
      if res&.is_a?(Hash) && res["errors"].present?
        error = res["errors"].map{|m| m["message"] }.join(", ")
        raise error
      else
        Rails.logger.info "[BungoAPI] #{method} #{path}"
        res
      end
    rescue => error
      Rails.logger.error "[BungoAPI] #{method} #{path}, Error: #{error}"
      raise error
    end
  end
end