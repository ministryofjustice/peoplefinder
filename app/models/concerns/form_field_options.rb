module Concerns::FormFieldOptions
  extend ActiveSupport::Concern

  included do
    WEEK_DAYS = [
      :works_monday,
      :works_tuesday,
      :works_wednesday,
      :works_thursday,
      :works_friday
    ].freeze

    DAYS_WORKED = [
      *WEEK_DAYS,
      :works_saturday,
      :works_sunday
    ].freeze

    def works_weekends?
      works_saturday || works_sunday
    end

    BUILDING_OPTS = [
      :whitehall_55,
      :whitehall_3,
      :victoria_1,
      :horse_guards,
      :king_charles
    ].freeze

    KEY_SKILL_OPTS = %w{
      accounting
      agile_delivery
      auditing
      briefing_ministers
      change_management
      communications
      commercial_awareness
      crm
      data_analysis
      financial_reporting
      knowledge_sharing
      legal_writing
      legislation
      negotiation
      marketing
      ministerial_briefing
      operational_delivery
      parliamentary_business
      planning
      policy
      project_delivery
      risk_management
      speech_writing
      statistics
      strategy
      submission
      training
      underwriting
      valution
      media_trained
      economist
      law
      research_operational
      research_economic
      research_statistical
      research_social
      research_user
      it
      information_management
      content_design
      graphic_design
      ux_design
      marketing
      contract_management
      project_management
      asset_management
      tax
      digital_workspace_publisher
      commercial_specialise
      income_generation
      sponsorship
      credit_risk_analysis
      digital
      interviewing
      project_finance
      presenting
    }.freeze
  end
end
