class Chat < ApplicationRecord
  belongs_to :application
  has_and_belongs_to_many :users
  has_many :messages

  # has_many :messages, dependent: :destroy
end
