module SearchHelper
  def access_count_stars(star_count)
    content_tag(:span) do
      1.upto(3) do |i|
        outline = (star_count >= i) ? 'fas' : 'far' # farがoutline
        concat content_tag(:i, '', class: "fa-star yellow #{outline}")
      end
    end
  end

  def category_label(category)
    color = case category[:id]
      when 'flash'
        'orange'
      when 'shortshort'
        'pink'
      when 'short'
        'blue'
      when 'novelette'
        'green'
      when 'novel'
        ''
      when 'shortnovel'
        'violet'
      when 'longnovel'
        'brown'
    end

    content_tag(:div, category[:name], class: "ui basic #{color} mini label")
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
