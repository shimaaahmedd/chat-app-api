class Message < ApplicationRecord
  belongs_to :chat
  belongs_to :user
  validates :body, presence: true
  validates :number, uniqueness: { scope: :chat_id }

  include Searchable
end
