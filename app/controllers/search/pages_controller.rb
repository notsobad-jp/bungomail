class Search::PagesController < Search::ApplicationController
  def about
    @page_title = t :about, scope: [:search, :controllers, :pages]

    @meta_title = @page_title
    @meta_description = @page_title
    @meta_keywords = @page_title
    @meta_canonical_url = url_for(juvenile: nil)
    @breadcrumbs << { name: @page_title }

    render 'about'
  end

  def ranking
    book_ids = [92, 45630, 427, 51034, 46268, 637, 42316, 46605, 3368, 56839, 16034, 2423, 18335, 58054, 3804, 624, 773, 46694, 46346, 1564, 411, 43403, 236, 424, 98, 4723, 228, 50326, 43736, 1130, 4276, 789, 46421, 3814, 2093, 1567, 4996, 127, 46710, 52409, 57197, 627, 4683, 799, 56648, 767, 58465, 2656, 752, 1758, 301, 1562, 2317, 43754, 473, 4675, 628, 3615, 52348, 54975, 49986, 57190, 43535, 43752, 42606, 56693, 56655, 42926, 1565, 1572, 47552, 4190, 442, 456, 46860, 2378, 46717, 45038, 42928, 1604, 42365, 419, 2657, 466, 144, 46709, 46823, 42308, 42883, 45716, 46511, 56033, 49202, 51512, 58278, 57021, 265, 275, 1040, 544]
    @books = Book.where(id: book_ids).order_by_ids(book_ids)

    @author = @book = {}
    @page_title = "ブンゴウサーチ年間アクセスランキング【2020】"
    @meta_title = @page_title
    @meta_description = @page_title
    @meta_keywords = @page_title
    @meta_canonical_url = url_for(juvenile: nil)
    @breadcrumbs << { name: "ランキング(2020)" }
    cloudinary_text = "年間アクセスランキング%0Aトップ100作品%0A【2020】"
    @meta_image = "https://res.cloudinary.com/notsobad/image/upload/y_-10,l_text:Roboto_80_line_spacing_15_text_align_center_font_antialias_good:#{cloudinary_text.delete(',').gsub('\'', '%27')}/v1585631765/ogp_#{lang_locale}.png"
  end
end
