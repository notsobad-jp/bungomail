module ApplicationHelper
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
end
