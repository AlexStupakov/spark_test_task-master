class ProductsUpload < ApplicationRecord
  has_attached_file :csvfile
  validates :csvfile, presence: true
  validates_attachment :csvfile,
                       content_type: { content_type: ['text/plain', 'text/csv'],
                                       message: "is not in CSV format" },
                       size: { less_than: 1.megabyte }
end
