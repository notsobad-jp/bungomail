# == Schema Information
#
# Table name: chapters
#
#  id         :bigint(8)        not null, primary key
#  book_id    :bigint(8)
#  index      :integer
#  text       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Chapter < ApplicationRecord
  belongs_to :book

  def next_chapter
    Chapter.find_by(book_id: self.book_id, index: self.index + 1)
  end
end
