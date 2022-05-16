class CreateChatsUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :chats_users, id:false do |t|
      t.belongs_to :chat
      t.belongs_to :user
    end
  end
end
