class SiteHistory < ApplicationRecord
  REFRESH_TIME = 30.days

  validates :url, presence: true, format: { with: URI.regexp(%w[http https]), message: "must be a valid URL" }

  def self.fetch_url(url)
    site_history = where(url: url).order(created_at: :desc).first

    if site_history && (site_history.created_at > REFRESH_TIME.ago)
      site_history.html
    else
      fetch_url!(url)
    end
  end

  def self.fetch_url!(url)
    response = HTTParty.get(url)

    if response.success?
      create!(
        url: url,
        html: response.body
      )

      response.body
    else
      # handle error
      StandardError.new("Error fetching data: HTTP #{response.code}")
    end
  end
end
