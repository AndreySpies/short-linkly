class ShortLinksController < ApplicationController
  before_action :set_short_link, only: [:show, :analytics]

  def show
    if @short_link
      @short_link.increase_accesses
      redirect_to @short_link.long_link, status: :moved_permanently and return
    end
  end

  def create
    base_url = request.base_url

    @short_link = ShortLink.find_by(short_link_params)
    if @short_link
      render json: @short_link,
        url: base_url,
        serializer: NewShortLinkSerializer,
        status: :created and return
    end

    @short_link = ShortLink.new(short_link_params)
    if @short_link.save
      render json: @short_link, url: base_url, serializer: NewShortLinkSerializer, status: :created
    else
      render json: @short_link.errors, status: :unprocessable_entity
    end
  end

  def analytics
    render json: @short_link, url: request.base_url, serializer: AnalyticsShortLinkSerializer
  end

  private

  def set_short_link
    @short_link = ShortLink.find_by_encoded_id(params[:id])

    head :not_found unless @short_link
  end

  def short_link_params
    params.permit(:long_link, :user_id)
  end
end
