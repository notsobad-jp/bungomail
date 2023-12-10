module SearchHelper
  def access_count_stars(star_count)
    content_tag(:span) do
      1.upto(3) do |i|
        concat content_tag(:span, star_count >= i ? '★' : '☆', class: "text-yellow-500")
      end
    end
  end

  def category_label(category)
    text_color, border_color = case category[:id]
      when 'flash'
        ['text-yellow-600', 'border-yellow-600']
      when 'shortshort'
        ['text-pink-600', 'border-pink-600']
      when 'short'
        ['text-blue-600', 'border-blue-600']
      when 'novelette'
        ['text-green-600', 'border-green-600']
      when 'novel'
        ['', '']
      when 'shortnovel'
        ['text-purple-700', 'border-purple-700']
      when 'longnovel'
        ['text-yellow-800', 'border-yellow-800']
    end

    content_tag(:span, category[:name], class: "text-xs rounded border px-2 py-1 #{text_color} #{border_color}")
  end

  def jsonld_breadcrumb(breadcrumbs)
    items = []
    @breadcrumbs.each.with_index(1) do |bread, index|
      items << {
        "@type": "ListItem",
        "position": index,
        "name": bread[:name],
        "item": bread[:url] || url_for(only_path: false)
      }
    end

    {
      "@context": "https://schema.org",
      "@type": "BreadcrumbList",
      "itemListElement": items
    }.to_json
  end

  def locale_root_url(locale: lang_locale, juvenile: params[:juvenile])
    # :jaのときはlocaleをパスに入れない
    # juvenileなどで空パスになって//enなどになるケースがあるので、力技で修正
    locale = nil if lang_locale == :ja
    search_root_url(locale: locale, juvenile: juvenile).gsub(/\/\/(en|juvenile)/, '/\1')
  end

  # 書き出しのtruncate文字数をlocaleで変える
  def truncated_beginning(beginning)
    beginning.truncate( (lang_locale == :en) ? 100 : 50 ) if beginning
  end

  # juvenileを無視した本当のlocaleを返す
  def lang_locale
    I18n.locale.slice(0,2).to_sym
  end

  def producthunt_launched?
    Time.zone.parse('2020/06/28 16:00:00') <= Time.zone.now
  end
end
