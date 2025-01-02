require 'open-uri'

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

  def aozora_card_url
    "https://www.aozora.gr.jp/cards/#{format('%06d', author_id)}/card#{id}.html"
  end

  def aozora_file_path
    file_path = fileId ? "#{id}_#{fileId}" : id
    "tmp/aozorabunko/cards/#{format('%06d', author_id)}/files/#{file_path}.html"
  end

  # scrape and parse Aozora File
  def aozora_file_text(html=nil)
    # html = html || Rails.env.production? ? URI.open(aozora_raw_file_url)&.read : File.open(aozora_file_path, &:read)
    html = html || URI.open(aozora_raw_file_url)&.read

    charset = 'CP932'
    doc = Nokogiri::HTML.parse(html, nil, charset)

    # ルビと外字(img)のtagを外してプレーンテキストにする
    rubys = {}
    doc.search('ruby').each do |ruby|
      # ルビ内に外字がある場合、外字を*に置き換えてルビを削除（あとで同じ外字に一括ルビ振り）
      if ruby.css('rb img.gaiji').first
        ruby.css('rb img.gaiji').each do |img|
          img.replace('※'.encode('Shift_JIS', invalid: :replace, undef: :replace))
        end
        rb = ruby.css('rb').inner_text
        rubys[rb] = "#{rb}（#{ruby.css('rt').inner_text}）"
        ruby.replace(rb.encode('Shift_JIS', invalid: :replace, undef: :replace))
      # 外字なしのルビは、常用漢字の有無でルビを残すか判定
      else
        rb = ruby.css('rb').inner_text
        # 常用漢字なし：ルビを残す
        if (rb.split('') & USUAL_KANJIS).empty?
          ruby.replace("#{rb}（#{ruby.css('rt').inner_text}）".encode('Shift_JIS', invalid: :replace, undef: :replace))
        # 常用漢字あり：ルビを削除
        else
          ruby.replace(rb.encode('Shift_JIS', invalid: :replace, undef: :replace))
        end
      end
    end
    # ルビなしの外字はすべて*に置換（一度ルビが振られてたものは後で一括ルビ振り）
    doc.search('img.gaiji').each do |img|
      img.replace('※'.encode('Shift_JIS', invalid: :replace, undef: :replace))
    end

    # 古いファイルは.main_textがないので、body配下の全文を本文扱いする
    main_text = doc.css('.main_text').presence || doc.css('body')
    text = main_text.inner_text
                    .gsub(/(\R{1,})/, '\1' + "\r\n") # 元からある改行を1つ増やす
                    .gsub(/\R/, "\r\n") # 改行コードを\r\nに変える
                    .gsub(/#{rubys.keys.join("|")}/, rubys) # 外字にルビを振る
                    .gsub(/(。)(?=[^（]*）|[^「]*」)/, '★★★') # （）と「」内の文末句点を★★★に一時変更
                    .gsub(/(。)/, '\1' + "\r\n") # その他の句点に改行追加
                    .gsub(/★★★/, '。') # ★を句点に戻す
                    .strip
    footnote = doc.css('.bibliographical_information').inner_text.strip

    [text, footnote]
  end

  def aozora_file_url
    file_path = fileId ? "#{id}_#{fileId}" : id
    "https://www.aozora.gr.jp/cards/#{format('%06d', author_id)}/files/#{file_path}.html"
  end

  def aozora_raw_file_url
    file_path = fileId ? "#{id}_#{fileId}" : id
    "https://raw.githubusercontent.com/aozorabunko/aozorabunko/master/cards/#{format('%06d', author_id)}/files/#{file_path}.html"
  end

  def author_name
    author["fullName"]
  end

  def author_id
    author["id"]
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

  def contents(chars_per: 700, count: nil)
    text = self.aozora_file_text[0]
    # 日数指定があればその数で分割、なければ文字数ベースでいい感じに分割
    if !count
      count = text.length.quo(chars_per).ceil
      count = count.quo(30).ceil * 30 if text.length > 12_000 # 12000字以上の場合は、30日単位で割り切れるように調整
    end
    chars_per = text.length.quo(count).ceil

    contents = []
    text.each_char.each_slice(chars_per).map(&:join).each_with_index do |content, index|
      if index.zero?
        contents[index] = content.gsub(/^(\r\n|\r|\n|\s|\t)/, '') # 冒頭の改行を削除
        next
      end

      # 最初の「。」で分割して、そこまでは前の回のコンテンツに所属させる。
      ## 会話文などの場合は、後ろ括弧までを区切りの対象にする：「ほげ。」[[TMP]]
      splits = content.sub(/([。！？][」）]|[。！？!?.])/, '\1' + '[[TMP]]').split('[[TMP]]', 2)

      ## 句点がなくて区切れない場合は、やむをえず読点で区切る
      unless splits[1]
        splits = content.sub(/(、)/, '\1' + '[[TMP]]').split('[[TMP]]', 2)
        no_period = true
      end

      ## 読点すらない場合は前回への追加はスキップ
      splits = ['', content] unless splits[1]

      contents[index - 1] += splits[0]

      # 前日の最後の１文を再掲する
      ## 句点がなかった場合は読点で区切る
      ## 句点すらなかった場合はlast_sentenceに全文入るけど、最後に文字数でスライスするのでOK
      regex = no_period ? /(、)/ : /([。！？][」）]|[。！？!?.])/
      last_sentence = contents[index - 1].gsub(regex, '\1' + '[[TMP]]').split('[[TMP]]')[-1]
      last_sentence = '…' + last_sentence.slice(-150..-1) if last_sentence.length > 150

      contents[index] = (last_sentence + splits[1]).gsub(/^(\r\n|\r|\n|\s|\t)/, '') # 冒頭の改行を削除
    end
    contents
  end

  def recommended_duration
    if wordsCount < 25000
      days = [wordsCount.fdiv(750).ceil, 30].min
      "#{days}日"
    else
      "#{wordsCount.fdiv(22500).ceil}ヶ月"
    end
  end

  def text
    content = OpenURI.open_uri(aozora_raw_file_url, 'r:CP932')&.read
    content&.encode('UTF-8', 'CP932', invalid: :replace, undef: :replace)
  rescue OpenURI::HTTPError => e
    Rails.logger.error "Failed to fetch text for book #{id}: #{e.message}"
    nil
  rescue Encoding::InvalidByteSequenceError => e
    Rails.logger.error "Encoding error for book #{id}: #{e.message}"
    nil
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