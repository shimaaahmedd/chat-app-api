class Application < ApplicationRecord
    has_secure_token
    has_many :chats, dependent: :destroy
    # has_many :messages, through: :chats,  dependent: :destroy
    validates :name, presence: true, uniqueness: true
    
end