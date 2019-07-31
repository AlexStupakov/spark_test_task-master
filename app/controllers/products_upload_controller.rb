class ProductsUploadController < ApplicationController
  require 'csv'

  def new
    @products_upload = ProductsUpload.new
  end

  def get_category_id(category_name)
    categories_hash[category_name] ||
      Spree::ShippingCategory.create(name: category_name)

  end

  def create
    @products_upload = ProductsUpload.new(products_upload_params)
    if @products_upload.save
      categories_hash = Spree::ShippingCategory.pluck(:name, :id).to_h
      CSV.foreach(@products_upload.csvfile.path, { :col_sep => ';',
                                                   headers: true,
                                                   skip_blanks: true }) do |row|
        next if row.to_h.values.all? { |column| column.nil? || column.strip.empty? }
        category_id =
          categories_hash[row['category']] ||
            categories_hash.merge(row['category'] =>
                                  Spree::ShippingCategory.create(name: row['category']).id
                                  ).values.last

        product = Spree::Product.new( name: row['name'],
                                      available_on: Time.parse(row['availability_date']),
                                      slug: row['slug'],
                                      description: row['description'],
                                      shipping_category_id: category_id,
                                      price: row['price'])
        product.save
        product.master.stock_items.first.update_attributes(count_on_hand: row['stock_total'])
      end
      redirect_to '/admin/products'
    else
      render :new
    end
  end

  private

  def products_upload_params
    params.require(:products_upload).permit(:csvfile, :user_id)
  end

end
