class WatchlistMailer < ActionMailer::Base
  default from: Settings.mail_from
  def commit_email(template_params)

    @template_params = template_params
    # email, name, token, entity
    date = Date.today.strftime('%d/%m/%Y')
    @template_params[:date] = date
    mail(to: @template_params[:email], subject: "Parliamentary Questions allocated #{date}")
  end
end
