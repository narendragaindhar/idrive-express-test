class DriveEvent < ApplicationRecord
  belongs_to :drive
  belongs_to :user

  validates :drive, presence: true
  validates :event, presence: true
  validates :user, presence: true
end
