class GroupUpdateService
  def initialize(group:, person_responsible:)
    @group = group
    @person_responsible = person_responsible
  end

  def update(params)
    @group.update(params).tap { |ok| inform_subscribers if ok }
  end

  private

  def inform_subscribers
    @group.subscribers.each do |subscriber|
      GroupUpdateMailer.
        inform_subscriber(subscriber, @group, @person_responsible).
        deliver_later
    end
  end
end
