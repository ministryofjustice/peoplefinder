class AOTokenFilter
  def self.before(controller)
    if !has_access(controller)
      controller.render :file => "public/401.html", :status => :unauthorized
    end
  end

  def self.has_access(controller)

    token_service = TokenService.new

    token = controller.params[:token]
    entity = controller.params[:e]
    path = controller.request.path

    puts "request data '#{token}' entity:'#{entity}', path:'#{path}'"

    is_valid = token_service.is_valid(token, path, entity)

    puts "== is_valid #{is_valid}"
    return is_valid
  end
end