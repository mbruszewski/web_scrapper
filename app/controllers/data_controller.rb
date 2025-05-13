class DataController < ApplicationController
  def new
    @scraper_data = ScraperData.new
  end

  def create
    @scraper_data = ScraperData.new(scraped_data_params)
    if @scraper_data.valid?
      # Process the scraped data here
      # For example, save it to the database or perform some action
      #
      web_scrapper_service = WebScrapperService.new(@scraper_data)
      @scraper_output = web_scrapper_service.call

      render :new
    else
      render :new
    end
  end

  private

  def scraped_data_params
    params.require(:scraper_data).permit(:url, :fields)
  end
end
