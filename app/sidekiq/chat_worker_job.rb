class ChatWorkerJob
  include Sidekiq::Job
  sidekiq_options queue: :chat
  # sidekiq_options lock: :while_executing

  def perform(application_id, user_id)
    Application.transaction do
      application = Application.find(application_id).lock!
      user = User.find(user_id)
      number = application.chats_count + 1
      application_chat = application.chats.create!(number:number, messages_count: 0)
      application_chat.users << user
      application.update(chats_count: number)
    end
  end
end