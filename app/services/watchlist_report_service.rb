class WatchlistReportService

  def initialize(tokenService = TokenService.new)
    @tokenService = tokenService
  end


  def send
    result = Hash.new
    WatchlistMember.all.each do |member|
      token = send_one(member)
      result[member.id] = token
    end
    result
  end


  def send_one(member)
    path = '/watchlist/dashboard'
    entity = "watchlist:#{member.id}"
    midnight = DateTime.now.midnight.change({:offset => 0})
    token = @tokenService.generate_token(path, entity, midnight)

    template = Hash.new
    template[:name] = member.name
    template[:entity] = entity
    template[:email] = member.email
    template[:token] = token

    WatchlistMailer.commit_email(template).deliver
    return token
  end
end