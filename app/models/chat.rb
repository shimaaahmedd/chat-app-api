class Chat < ApplicationRecord
  belongs_to :application
  has_and_belongs_to_many :users
  has_many :messages, dependent: :destroy
  validates :number, uniqueness: { scope: :application_id}

end
