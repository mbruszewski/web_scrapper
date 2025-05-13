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
    meta = fields.delete(:meta)

    ret = fields.each_with_object({}) do |(key, selector), result|
      element = nokogiri_html.at_css(selector)
      value = element ? element.text.strip : ""
      result[key] = value
    end

    ret[:meta] = meta.each_with_object({}) do |(selector), result|
      result[selector.to_sym] = nokogiri_html.at_css("meta[name='#{selector}']")&.attribute("content")&.value || ""
    end if meta

    ret
  end

  private

  def handle_error(code)
    puts "Error fetching data: HTTP #{code}"
  end

  def handle_exception(exception)
    puts "An error occurred: #{exception.message}"
  end
end
