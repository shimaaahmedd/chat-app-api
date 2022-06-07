class UsersController < ApplicationController
  before_action :set_user, only: [:show]
  skip_before_action :authenticate, only: [:create]


  # GET /users
  def index
    @users = User.all
    render json: @users.to_json(only: [:email, :first_name, :second_name])
  end

  # GET /users/1
  def show
    render json:
    {
        email: @user.email,
        first_name: @user.first_name,
        second_name: @user.second_name,
        token: token
    }
  end

  # POST /register
  def create
    @user = User.new(user_params)
    payload = { user_id: @user.id}
    token = create_token(payload)
    if @user.save
      render json: 
       {
          email: @user.email,
          first_name: @user.first_name,
          second_name: @user.second_name,
          token: token
       }, status: :created, location: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PUT /update
  def update
    if @user.update(user_params)
      render json: {
        email: @user.email,
        first_name: @user.first_name,
        second_name: @user.second_name,
        token: token
     }
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /delete
  def destroy
    @user.destroy
    redirect_to logout_path
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      return render json: { message: "No user found with this ID" }, status: :forbidden unless User.exists?(params[:id])
      @user = User.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def user_params
      params.require(:user).permit(:first_name, :second_name, :email, :password, :password_confirmation)
    end
end
