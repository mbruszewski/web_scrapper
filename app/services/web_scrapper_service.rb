class WebScrapperService
  attr_accessor :scraper_data

  def initialize(scraper_data)
    @scraper_data = scraper_data
  end

  def call
    begin
      response = fetch_data

      if response.success?
        parse_data(response.body)
      else
        handle_error(response.code)
      end
    rescue StandardError => e
      handle_exception(e)
    end
  end

  def fetch_data
    HTTParty.get(scraper_data.url)
  end

  def parse_data(data)
    nokogiri_html = Nokogiri::HTML(data)
    fields = scraper_data.fields

    fields.each_with_object({}) do |(key, selector), result|
      element = nokogiri_html.at_css(selector)
      value = element ? element.text.strip : ""
      result[key] = value
    end
  end

  private

  def handle_error(code)
    puts "Error fetching data: HTTP #{code}"
  end

  def handle_exception(exception)
    puts "An error occurred: #{exception.message}"
  end
end
