require 'test_helper'

class ChatsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @chat = chats(:one)
  end

  test "should get index" do
    get chats_url, as: :json
    assert_response :success
  end

  test "should create chat" do
    assert_difference('Chat.count') do
      post chats_url, params: { chat: { application_id: @chat.application_id, messages_count: @chat.messages_count, number: @chat.number, user_id: @chat.user_id } }, as: :json
    end

    assert_response 201
  end

  test "should show chat" do
    get chat_url(@chat), as: :json
    assert_response :success
  end

  test "should update chat" do
    patch chat_url(@chat), params: { chat: { application_id: @chat.application_id, messages_count: @chat.messages_count, number: @chat.number, user_id: @chat.user_id } }, as: :json
    assert_response 200
  end

  test "should destroy chat" do
    assert_difference('Chat.count', -1) do
      delete chat_url(@chat), as: :json
    end

    assert_response 204
  end
end
