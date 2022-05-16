class Application < ApplicationRecord
    has_secure_token
    has_many :chats, dependent: :destroy
    # has_many :messages, through: :chats,  dependent: :destroy

    validates_presence_of :name, uniqueness: true

    
end