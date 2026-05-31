class CreateAssets < ActiveRecord::Migration[5.0]
  def change
    create_table :assets do |t|
      t.references :post, foreign_key: true
      t.string :name, null: false
    end
  end
end
