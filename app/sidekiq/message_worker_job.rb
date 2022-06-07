class MessageWorkerJob
    include Sidekiq::Job
    sidekiq_options queue: :message
  
    def perform(application_id, chat_id, body, user_id)
      Application.transaction do
        application = Application.find(application_id)
        chat = application.chats.find(chat_id).lock!
        user = User.find(user_id)
        number = chat.messages_count + 1
        app_chat_msg = chat.messages.create!(body: body, user: user, number: number)
        chat.update(messages_count: number)
      end
    end
  
  end