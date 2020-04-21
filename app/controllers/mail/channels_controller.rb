class Mail::ChannelsController < Mail::ApplicationController
  before_action :set_channel, except: [:new, :create]

  def new
    @channel = Channel.new
    @breadcrumbs << { name: 'New Channel' }
  end

  def create
    @channel = current_user.channels.new(channel_params)
    if @channel.save
      flash[:success] = 'Channel created!'
      redirect_to channel_path(@channel)
    else
      flash[:error] = 'Sorry somethin went wrong. Please check the data and try again.'
      render :new
    end
  end

  def edit
    @breadcrumbs << { name: 'Edit Channel' }
  end

  def update
    if @channel.update(channel_params)
      flash[:success] = 'Channel updated!'
      redirect_to channel_path(@channel)
    else
      flash[:error] = 'Sorry somethin went wrong. Please check the data and try again.'
      render :edit
    end
  end

  def show
    @book_assignment = @channel.current_book_assignment
    @stocked_books = @channel.book_assignments.stocked

    @breadcrumbs << { name: @channel.title || "Default Channel" }
  end

  def destroy
    @channel.destroy
    flash[:success] = 'Deleted the channel successfully!'
    redirect_to mypage_path
  end

  private

  def channel_params
    params.require(:channel).permit(:title, :description, :public, :delivery_time, :words_per_day, :chars_per_day)
  end

  def set_channel
    @channel = Channel.find(params[:id])
  end
end