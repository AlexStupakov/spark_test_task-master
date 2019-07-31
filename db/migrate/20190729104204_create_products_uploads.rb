class CreateProductsUploads < ActiveRecord::Migration[5.1]
  def change
    create_table :products_uploads do |t|
      t.attachment :csvfile
      t.integer :user_id

      t.timestamps
    end
  end
end
