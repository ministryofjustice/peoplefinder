require 'csv'

class UserCSVRenderer
  def initialize(user, aggregator = TabularReviewAggregator.new(user.reviews))
    @user = user
    @aggregator = aggregator
  end

  def to_csv
    CSV.generate { |csv|
      csv << [translate(:name), @user.to_s]
      csv << []
      @aggregator.each do |row|
        csv << row.map { |c| translate(c) }
      end
    }
  end

  def translate(name, options = {})
    case name
    when Symbol
      I18n.t(name, options.merge(scope: 'helpers.label.submission'))
    else
      name
    end
  end
end
