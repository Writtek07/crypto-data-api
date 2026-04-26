class CreatePrices < ActiveRecord::Migration[7.2]
  def change
    create_table :prices do |t|
      t.string :coin_name
      t.string :coin_symbol
      t.decimal :latest_price, precision: 10, scale: 2
      t.datetime :last_price_fetch_at

      t.timestamps
    end
  end
end
