class ScraperData
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :url, :fields

  validates :url, presence: true, format: { with: URI.regexp(%w[http https]), message: "must be a valid URL" }
  validates :fields, presence: true

  def initialize(params = {})
    @url = params[:url]
    @fields = params[:fields]
  end
end
