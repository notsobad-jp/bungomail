require 'open-uri'
require 'csv'

class GutenBook < ApplicationRecord
  has_and_belongs_to_many :subjects
  has_many :distributions, as: :book, dependent: :restrict_with_exception
  has_many :variants, class_name: 'GutenBook', foreign_key: :canonical_book_id
  belongs_to :canonical, class_name: 'GutenBook', foreign_key: :canonical_book_id, required: false

  default_scope { where(language: :en).where.not(id: EXCLUDE_IDS) }
  scope :sorted, -> { order(downloads: :desc) }

  # アクセス数に対する評価(download数)
  ## ratingは JSON-LDで表示するメタ評価
  ## starsはサイト上で表示する星の数
  ACCESS_RATINGS = {
    50 => { rating: 5,   stars: 3 },
    15 =>   { rating: 4.5, stars: 2 },
    1 =>     { rating: 4,   stars: 1 },
    0 =>     { rating: 3,   stars: 0 }
  }.freeze

  # 中身がない作品を検索結果から除外する
  EXCLUDE_IDS = [25525, 3206, 11262, 31565, 29004, 11261, 4742, 28876, 30580, 30153, 4663, 8421, 28747, 28760, 28821, 42911, 29434, 30152, 8215, 29441]

  WORDS_PER_MINUTES = 300
  CATEGORIES = {
    all: {
      id: 'all',
      name: 'all',
      range_from: 1,
      range_to: 9999999,
      books_count: 35142,
    },
    flash: {
      id: 'flash',
      name: '5min',
      title: 'flash',
      range_from: 1,
      range_to: WORDS_PER_MINUTES * 5,
      books_count: 579,
    },
    shortshort: {
      id: 'shortshort',
      name: '10min',
      title: 'short short',
      range_from: WORDS_PER_MINUTES * 5 + 1,
      range_to: WORDS_PER_MINUTES * 10,
      books_count: 681,
    },
    short: {
      id: 'short',
      name: '30min',
      title: 'short',
      range_from: WORDS_PER_MINUTES * 10 + 1,
      range_to: WORDS_PER_MINUTES * 30,
      books_count: 3420,
    },
    novelette: {
      id: 'novelette',
      name: '1h',
      title: 'novelette',
      range_from: WORDS_PER_MINUTES * 30 + 1,
      range_to: WORDS_PER_MINUTES * 60,
      books_count: 4478,
    },
    shortnovel: {
      id: 'shortnovel',
      name: '2h',
      title: 'short novel',
      range_from: WORDS_PER_MINUTES * 60 + 1,
      range_to: WORDS_PER_MINUTES * 120,
      books_count: 5672,
    },
    novel: {
      id: 'novel',
      name: '3h',
      title: 'novel',
      range_from: WORDS_PER_MINUTES * 120 + 1,
      range_to: WORDS_PER_MINUTES * 180,
      books_count: 5630,
    },
    longnovel: {
      id: 'longnovel',
      name: 'over 3h',
      title: 'long novel',
      range_from: WORDS_PER_MINUTES * 180 + 1,
      range_to: 9999999,
      books_count: 14666,
    },
  }.freeze


  def access_rating(type = :rating)
    ACCESS_RATINGS.find{|k,v| self.downloads >= k }.dig(1, type)
  end

  def amazon_search_url
    "https://www.amazon.com/s?k=#{author_name&.slice(0..70)}+#{title&.slice(0..30)}&i=stripbooks-intl-ship"
  end

  def author_name
    GutenBook.author_name(author)
  end

  def first_sentence
    str = text.slice(0, 5000)
    str = str.split(/Produced by .*/i).last
    str = str.split(/Proofreading Team.*$/i).last
    str = str.split(/\[Transcriber's Note:.*publication was renewed\.\]/m).last
    str = str.split(/\[?_?All rights reserved\._?\]?/i).last
    if author_name
      name = author_name.split(" ").join("(.*)\s+")
      str = str.split(/by\s+.*#{name}.*$/i).last # by + 著者名。微妙に表記ゆれがあるので前後に他の文字が入っても区切る
    end
    str = str.split(/^\s*#{title}\s*$/i).last # タイトル＋空白だけの行があればそこで区切る
    str = str.split(/(\s*Chapter\s*[IVX0-9]+[^\r\n]+[\r?\n]+){3,}/m).last # 目次行（Chapter + 数字＋文字列が改行区切りで3行以上続くエリア）を除外
    str = str.split(/(\s*[IVX0-9]+\. [^\r\n]+[\r?\n]+){3,}/m).last # 目次行（数字 + . + 文字列が改行区切りで3行以上続くエリア）を除外
    str = str.sub(/(Chapter\s*[I1](?:\s|\.)+)/i, '[[CHAPTER1]]\1').split("[[CHAPTER1]]").last # 目次を除いたあとに「Chapter 1/I」があればそこからスタート
    sentence = str.sentences.reject{|s| s == s.upcase }.first # 全部大文字の行は除外
    sentence&.strip&.gsub(/\r\n|\r|\n/, " ")
  end

  def gutenberg_book_url
    "https://www.gutenberg.org/ebooks/#{id}"
  end

  def gutenberg_text_url
    "https://www.gutenberg.org/cache/epub/#{id}/pg#{id}.txt"
  end

  # 加工前のテキストファイル。本番はGutenbergから、それ以外ではlocalファイルから返す
  def raw_text
    if Rails.env.production?
      open(gutenberg_text_url).read
    else
      # developmentではtmp、testではtest/fixturesのファイルを返す
      local_file = Rails.env.development? ? "tmp/gutenberg/text/#{id}/pg#{id}.txt.utf8.gzip" : "spec/files/gutenberg/pg#{id}.txt.utf8.gzip"
      Zlib::GzipReader.new(open(local_file)).read
    end
  end

  # 不要な部分を除去したテキストファイル本文
  def text
    splited_text = raw_text.split(/\*\*\*\s?(START|END) OF (THIS|THE) PROJECT GUTENBERG EBOOK [^*]+\s?\*\*\*/)
    return if splited_text.size != 7
    splited_text[3].strip
  rescue => e
    p e
    nil
  end

  # 各回が指定文字数でいい感じに配信されるように分割する
  def contents(words_per: 400)
    # センテンスに分割（Stringクラス拡張）
    sentences = self.text.sentences

    contents = [""]
    contents_index = 0
    word_count = 0
    last_sentences = []

    sentences.each do |sentence|
      contents[contents_index] += sentence
      word_count += sentence.words.length

      # 文字数が設定を超えたら次に回す（最後の回はここを通ったり通らなかったりする）
      if word_count > words_per
        contents_index += 1
        word_count = 0
        contents[contents_index] = ""
        last_sentences << sentence.sub(/(\r\n|\r|\n)/," ") # 前回最後の一文を配列に保存しておく（最初の改行文字はずれることが多いのでスペースに置き換え）
      end
    end

    # 最後が短すぎるときは、一つ前のにマージして最終回を削除
    if contents.last.words.length < 200
      contents[-2] += contents[-1]
      contents.pop
    end

    # 各回最後の一文を次回の冒頭に追加
    contents.each_with_index do |content, index|
      next if index == 0
      last_sentence = last_sentences[index - 1]
      last_sentence = '…' + last_sentence.slice(-150..-1) if last_sentence.length > 150
      contents[index] = last_sentence + content
    end

    contents
  end

  def category
    CATEGORIES.dig(self.category_id&.to_sym)
  end

  def popularity
    self.downloads
  end

  # Gutenbergはファイル直リンクを禁止してるので、 詳細ページに飛ばす
  def original_file_url
    self.gutenberg_book_url
  end

  def update_beginning
    return if text.blank? || first_sentence.blank?
    update(beginning: first_sentence.truncate(200))
  end

  def update_ngsl(ngsl_words = nil)
    ngsl_words ||= CSV.read('db/seeds/ngsl.csv').pluck(0)
    unique_words = self.text.unique_words

    dup_words = (unique_words & ngsl_words)
    ratio = sprintf("%.1f", dup_words.count/unique_words.count.to_f * 100) if unique_words.count > 0

    self.update(
      ngsl_words_count: dup_words.count,
      unique_words_count: unique_words.count,
      ngsl_ratio: ratio,
    )

    dir = "tmp/gutenberg/ngsl/#{self.id}"
    FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
    File.write("#{dir}/#{self.id}.csv", (unique_words - dup_words).map{|w| [w].to_csv }.join)
  end


  class << self
    def author_name(author)
      return unless author.present?
      names = author.split(",").map(&:strip)
      names.length == 2 ? "#{names[1]} #{names[0]}" : author
    end

    # DB検索用に、表示名を実際の値に戻す
    def author_search_name(name)
      # name = name.split(' ').reverse.join(', ') if name.split(' ').length == 2
      name = name.gsub(/(.*) (.+)$/, '\2, \1') # 最初の半角スペースで分割して入れ替え
      name.delete(' ')
    end

    def category_range(category_id)
      category = CATEGORIES[category_id]
      return unless category

      case category_id
      when :flash
        "less than #{category[:range_to].to_s(:delimited)} words"
      when :longnovel
        "more than #{category[:range_from].to_s(:delimited)} words"
      else
        "#{category[:range_from].to_s(:delimited)} to #{category[:range_to].to_s(:delimited)} words"
      end
    end

    def import_rdf(id)
      file_path = "tmp/gutenberg/rdf/#{id}/pg#{id}.rdf"
      xml = File.open(file_path, &:read)

      charset = 'UTF-8'
      doc = Nokogiri::XML.parse(xml, nil, charset)
      title = doc.xpath('//dcterms:title').first.try(:text)
      author = doc.xpath('//dcterms:creator/pgterms:agent/pgterms:name').first.try(:text)
      author_id = doc.xpath('//dcterms:creator/pgterms:agent').first&.attributes&.dig("about")&.value&.split("/")&.last
      rights = doc.xpath('//dcterms:rights').first.try(:text)
      language = doc.xpath('//dcterms:language/rdf:Description/rdf:value').first.try(:text)
      downloads = doc.xpath('//pgterms:downloads').first.try(:text)
      subject_names = doc.xpath('//dcterms:subject/rdf:Description/rdf:value').map{|value| value.text.split('--').map(&:strip) }.flatten.uniq
      birth_year = doc.xpath('//dcterms:creator/pgterms:agent/pgterms:birthdate').first.try(:text)
      death_year = doc.xpath('//dcterms:creator/pgterms:agent/pgterms:deathdate').first.try(:text)

      subjects = []
      subject_names.each do |name|
        subjects <<  Subject.find_or_initialize_by(id: name)
      end

      return unless title
      book = GutenBook.find_or_initialize_by(id: id)
      book.update(
        title: title,
        author: author,
        author_id: author_id,
        rights_reserved: rights != 'Public domain in the USA.',
        language: language,
        downloads: downloads,
        subjects: subjects,
        birth_year: birth_year,
        death_year: death_year,
      )
      p "Imported: [#{id}] #{title}"
    rescue => e
      p e
    end

    def popular_authors(limit=15)
      self.limit(limit).where.not(author: [nil, 'Various', 'Anonymous']).order('sum_downloads desc').group(:author, :author_id).sum(:downloads)
    end

    def search(q)
      results = self.where.not(category_id: nil).where.not(author_id: nil).sorted
      results = results.where("title LIKE ?", "%#{q[:title]}%") if q[:title].present?
      results = results.where("author LIKE ?", "%#{q[:author]}%") if q[:author].present?
      results = results.where(category_id: q[:category]) if q[:category].present?

      if q[:popularity].present?
        min = ACCESS_RATINGS.find{|k,v| v[:stars] == q[:popularity].to_i }&.first
        max = ACCESS_RATINGS.find{|k,v| v[:stars] == q[:popularity].to_i + 1 }&.first
        results = results.where(downloads: min..max) # maxがない場合は上限なしの範囲選択(>=)になる
      end

      results
    end
  end
end
