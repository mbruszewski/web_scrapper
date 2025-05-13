require 'rails_helper'

RSpec.describe WebScrapperService do
  let(:scraper_data) { instance_double("ScraperData", url: "http://example.com", fields: fields) }
  let(:service) { described_class.new(scraper_data) }
  let(:fields) { { price: ".price" } }

  describe "#call" do
    context "task #1 - get multiple class fields" do
      let(:fields) do
        {
          price: ".price-box__price",
          rating_count: ".ratingCount",
          rating_value: ".ratingValue"
        }
      end
      let(:html_response) do
        <<-HTML
          <html>
            <head></head>
            <body>
              <div class="price-box__price">100 euro</div>
              <div class="ratingCount">50</div>
              <div class="ratingValue">4.5</div>
            </body>
          </html>
        HTML
      end

      it "fetches data from the URL" do
        allow(HTTParty).to receive(:get).with(scraper_data.url).and_return(double(success?: true, body: html_response))

        result = service.call

        expect(result).to eq({
          price: "100 euro",
          rating_value: "50",
          rating_count: "4.5"
        })
      end
    end
  end

  describe "#parse_data" do
    let(:fields) { { price: ".price", count: ".count" } }

    context "when the tag does not exist" do
      let(:html_data) { "<html><body><div class='price2'>100</div></body></html>" }

      it "returns empty values" do
        parsed_data = service.parse_data(html_data)

        expect(parsed_data).to eq({ price: "", count: "" })
      end
    end

    context "when one of the tags exists" do
      let(:html_data) { "<html><body><div class='price'>100</div></body></html>" }

      it "returns value for those found" do
        parsed_data = service.parse_data(html_data)

        expect(parsed_data).to eq({ price: "100", count: "" })
      end
    end

    context "when there is 'meta' tag" do
      let(:fields) { { meta: [ "description", "image-link" ], price: ".price", count: ".count" } }
      let(:html_data) { "<html><head><meta name='description' content='Test'></head><body><div class='price'>100</div></body></html>" }

      it "returns existing values" do
        parsed_data = service.parse_data(html_data)

        expect(parsed_data).to eq({ meta: { description: "Test", "image-link": "" }, price: "100", count: "" })
      end
    end
  end
end
