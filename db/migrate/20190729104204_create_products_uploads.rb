class CreateProductsUploads < ActiveRecord::Migration[5.1]
  def change
    create_table :products_uploads do |t|
      t.attachment :csvfile
      t.string :status
      t.string :import_errors

      t.timestamps
    end
  end
end
