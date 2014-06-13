class PQAcceptedMailer < ActionMailer::Base
  default from: "from@example.com"
  def commit_email(template_params)

    @template_params = template_params
    # email, name from AO
    # uin, question from PQ
    mail(to: @template_params[:email], subject: "[Parliamentary-Questions] #{@template_params[:uin]} | You have accepted the question")
  end
end
