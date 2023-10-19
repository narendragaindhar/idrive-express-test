class Address < ApplicationRecord
  belongs_to :addressable, inverse_of: :address, polymorphic: true

  validates :address, presence: true, length: { maximum: 255 }
  validates :city, presence: true, length: { maximum: 255 }
  validates :country, presence: true, length: { maximum: 255 }
  validates :recipient, presence: { unless: :organization? }, length: { maximum: 255 }
  validates :organization, presence: { unless: :recipient? }, length: { maximum: 255 }
  validates :zip, presence: true, length: { maximum: 255 }

  def full
    @full ||= [recipient, organization, address, city, state, zip, country].collect(&:presence).compact
  end

  def full_address
    full.join ', '
  end

  def location_line
    location = city
    location += ", #{state}" if state.present?
    "#{location} #{zip}"
  end

  def outside_usa?
    country.present? && country !~ /\A(u\.?s\.?a|united states( of america)?|america)\z/i
  end

  def to_field
    if recipient.present? && organization.present?
      "#{recipient} c/o #{organization}"
    else
      recipient.presence || organization
    end
  end
end
