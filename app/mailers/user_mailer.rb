class UserMailer < ApplicationMailer
	default from: 'Weather alert'

  def alert_email
    @user = params[:user]
    @info = params[:info]
    @state = params[:state]
    @subject = @state + " weather alert"
    mail(to: @user, subject: @subject)
  end
end
