class Product < ApplicationRecord
  has_many :customers, dependent: :restrict_with_exception
  has_many :order_types, dependent: :restrict_with_exception

  # validation
  validates :name, presence: true, length: { maximum: 255 }, uniqueness: true

  def is?(product)
    if product.is_a? Regexp
      !name.match(product).nil?
    else
      !name.downcase.match(product.to_s.downcase).nil?
    end
  rescue NoMethodError
    false
  end
end
