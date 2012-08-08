class SearchController < ApplicationController
  def index
    results = $asari.search(params[:q], page_size: params[:per], page: params[:page])
    render json: results
  end
end