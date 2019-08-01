class ProductsImportWorker
  include Sidekiq::Worker
  sidekiq_options retry: false
  require 'csv'
  def perform(csv_path)
    keys = %w[name description price availability_date slug stock_total category]
    categories_hash = Spree::ShippingCategory.pluck(:name, :id).to_h
    CSV.foreach(csv_path, { :col_sep => ';',
                                                 headers: true,
                                                 skip_blanks: true }) do |row|
      next if keys.any? {|key| !row.to_h.key?(key) || row.to_h[key].blank? }
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
  end
end
