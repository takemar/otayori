class CreateTables < ActiveRecord::Migration[5.0]
  def change
    create_table :posts do |t|
      t.string :title,       null: false
      t.string :slug,        null: false
      t.string :description, null: false
      t.string :format,      null: false
      t.string :source,      null: false
      t.timestamps           null: false
      t.index :created_at
    end

    create_table :tags do |t|
      t.string  :name,  null: false
      t.string  :slug,  null: false
      t.integer :order, null: false
      t.timestamps      null: false
      t.index :slug,                 unique: true
      t.index [:order, :updated_at], order: {order: :desc, updated_at: :asc}
    end

    create_join_table :posts, :tags do |t|
      t.index [:post_id, :tag_id],  unique: true
      t.index [:tag_id,  :post_id], unique: true
    end
  end
end
