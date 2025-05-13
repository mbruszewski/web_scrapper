RSpec.describe SiteHistory do
  describe ".fetch_url" do
    let(:url) { "http://example.com" }
    let!(:site_history) { SiteHistory.create(url: url, html: "<html></html>") }

    before do
      allow(HTTParty).to receive(:get).and_return(double(success?: true, body: "<html></html>"))
    end

    context "when the URL is found and within the refresh time" do
      it "returns the HTML" do
        expect(SiteHistory.fetch_url(url)).to eq("<html></html>")
        expect(HTTParty).not_to have_received(:get).with(url)
      end
    end

    context "when the URL is not found or outside the refresh time" do
      before do
        site_history.update(created_at: 31.days.ago)
      end

      it "fetches the URL again" do
        SiteHistory.fetch_url(url)
        expect(HTTParty).to have_received(:get).with(url)
      end
    end

    context "when there are 2 site_hostories with the same URL" do
      let!(:old_site_history) { SiteHistory.create(url: url, html: "<html></html>", created_at: 31.days.ago) }

      it "returns the most recent one and not call the site" do
        expect(SiteHistory.fetch_url(url)).to eq("<html></html>")
        expect(HTTParty).not_to have_received(:get).with(url)
      end
    end
  end

  describe ".fetch_url!" do
    let(:url) { "http://example.com" }
    let(:html) { "<html></html>" }

    it "creates a new record and returns the HTML" do
      expect(HTTParty).to receive(:get).with(url).and_return(double(success?: true, body: html))
      expect {
        SiteHistory.fetch_url!(url)
      }.to change(SiteHistory, :count).by(1)

      expect(SiteHistory.last.html).to eq(html)
    end
  end

  # generally I would prefer to use shoulda-matcher gem for this
  describe "validations" do
    it "validates presence of URL" do
      site_history = SiteHistory.new(url: nil)
      expect(site_history.valid?).to be_falsey
      expect(site_history.errors[:url]).to include("can't be blank")
    end

    it "validates format of URL" do
      site_history = SiteHistory.new(url: "invalid-url")
      expect(site_history.valid?).to be_falsey
      expect(site_history.errors[:url]).to include("must be a valid URL")
    end
  end
end
