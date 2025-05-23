class Profile < ApplicationRecord
  has_many :users

  validates :name, presence: true, uniqueness: true

  add_scope :search do |value|
    where('
      profiles.name LIKE :value
    ', value: "%#{value}%")
  end
end