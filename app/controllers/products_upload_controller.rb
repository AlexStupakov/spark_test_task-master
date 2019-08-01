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
      ProductsImportWorker.perform_async( @products_upload.csvfile.path, @products_upload.id)
      redirect_to '/admin/products', notice: "CSV file #{ @products_upload.csvfile.original_filename} processing started"
    else
      render :new
    end
  end

  private

  def products_upload_params
    params.require(:products_upload).permit(:csvfile, :user_id)
  end

end
