class CreateSiteHistories < ActiveRecord::Migration[7.2]
  def change
    create_table :site_histories do |t|
      t.string :url
      t.text :html

      t.timestamps
    end
  end
end
