class UsersController < ApplicationController
  before_action :authenticate_account!

  def index
    @all_tags = ActsAsTaggableOn::Tag.order('taggings_count desc')
    # Filter with ransack
    @q = current_account.users.includes(:user_attributes).ransack(params[:q])
    @q.sorts = 'created_at DESC' if @q.sorts.empty?
    if params[:limit_count].present?
      @users = @q.result(distinct: true).limit(params[:limit_count])
    else
      @users = @q.result(distinct: true).page(params[:page])
    end
  end

  def new; end

  def create
    if params[:file].present? && params[:tags].present?
      @result = current_account.import_users_from_csv(params[:file], params[:tags])
    else
      @result = { imported_users: 0, import_errors: 'Tags and Csv file required.' }
    end
    redirect_to new_user_path, notice: @result
  end

  def destroy
    @user = current_account.users.find params[:id]
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
end
