class User < ApplicationRecord
    has_secure_password
    validates :email, presence: true, uniqueness: true
    validates :first_name, :second_name, presence: true
    # has_and_belongs_to_many :chats, dependent: :destroy
    has_many :applications
    has_and_belongs_to_many :chats
  end
  