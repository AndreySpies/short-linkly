class ShortLinksController < ApplicationController
  before_action :set_short_link, only: [:show, :analytics]

  def show
    if @short_link
      @short_link.increase_accesses
      redirect_to @short_link.long_link, status: :moved_permanently and return
    end

    raise ActiveRecord::RecordNotFound, "Record not found."
  end

  def create
    user_id = params[:user_id]
    long_link = params[:long_link]

    @short_link = ShortLink.find_by(user_id: user_id, long_link: long_link)
    render_short_link and return if @short_link

    @short_link = ShortLink.new(user_id: params[:user_id], long_link: params[:long_link])
    if @short_link.save
      render_short_link
    else
      render json: @short_link.errors, status: :unprocessable_entity
    end
  end

  def analytics
    render_analytics
  end

  private

  def render_short_link
    hash = {
      "long_link": @short_link.long_link,
      "short_link": request.base_url + "/" + @short_link.encoded_id
    }

      render json: hash, status: :created
  end

  def render_analytics
    hash = {
      "short_link": request.base_url + "/" + @short_link.encoded_id,
      "long_link": @short_link.long_link,
      "accesses": @short_link.accesses
    }

    render json: hash, status: :ok
  end

  def set_short_link
    @short_link = ShortLink.find_by_encoded_id(params[:id])

    head :not_found unless @short_link
  end

  def short_link_params
    params.require(:short_link).permit(:long_link, :user_id)
  end
end
