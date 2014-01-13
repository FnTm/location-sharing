module ApplicationHelper
  def authenticate_user_from_token!
    user_email = params[:email].presence
    user       = user_email && User.find_by_email(user_email)

    # Notice how we use Devise.secure_compare to compare the token
    # in the database with the token given in the params, mitigating
    # timing attacks.
    if user && Devise.secure_compare(user.authentication_token, params[:authentication_token])
      self.resource = user
    end
    render :status => 401, :json => {errors: [t('api.v1.token.invalid_token')]} if self.resource.nil?
  end
end
