class UserMailer < ActionMailer::Base
  def signup_notification(user)
    setup_email(user)
    @subject += 'Please activate your new account'
    puts 'In Emailer: ' + user.activation_code.to_s
    @body[:url] = "#{HOST}activate/#{user.activation_code}"
  end
  def activation(user)
    setup_email(user)
    @subject += 'Your account has been activated!'
    @body[:url] = "#{HOST}"
  end
  protected
  def setup_email(user)
    @recipients = "#{user.email}"
    @from = 'do-not-reply@dhguild.net'
    @subject = 'Hiya - '
    @sent_on = Time.now
    @body[:user] = user
  end
end
