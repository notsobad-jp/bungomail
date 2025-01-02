class FeedsController < ApplicationController
  def show
    @feed = Feed.find(params[:id])
    @book = @feed.campaign.book
    @word_count = @feed.content.gsub(" ", "").length

    @meta_title = "#{@book.author_and_book_name}(#{@feed.index}/#{@feed.campaign.count}"
    @breadcrumbs = [ {text: @book.author_and_book_name, link: campaign_path(@feed.campaign)}, {text: @feed.index} ]
    @no_index = true
  end
end
