class ConfirmationsController < Devise::ConfirmationsController
  respond_to :html

  def show
    if User.confirm_by_token(params[:confirmation_token]).confirmed?
      render :show
    else
      render :error
    end
  end
end
