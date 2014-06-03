class PqMailer < ActionMailer::Base
  default from: "from@example.com"
  def commit_email(template_params)

  	@template_params = template_params
  	# email, name from AO
  	# uin, question from PQ
  	# url with the token
    mail(to: @template_params[:email], subject: 'You have been allocated a question')
  end
end
