# frozen_string_literal: true

class Campaign
  attr_accessor :id, :job_id, :status, :external_reference

  STATUSES = %w(active paused deleted).freeze

  def initialize(params)
    self.id = params[:id]
    self.job_id = params[:job_id]
    self.status = params[:status]
    self.external_reference = params[:external_reference]
  end
end
