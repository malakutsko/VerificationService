# frozen_string_literal: true

# Finds mismatches between local campaigns
# and campaigns on ad service
#
# input:
#   [campaign, campaign ... ] - array of local campaigns
#
# output:
#   [{ record: campaign, mismatches: [{ attr_name: string, local_value: value, ad_value: value }, { ... }, ...],
#      record: campaign, mismatches: [...] }, ...]

require_relative 'ad_service_api'

class VerificationService
  attr_accessor :local_records, :ad_records, :compare_params

  COMPARED_ATTRIBUTES_MAP = { status: :status, ad_description: :description }.freeze
  STATUSES_MAP = { active: 'enabled', paused: 'disabled', deleted: 'disabled' }.freeze

  def initialize(local_records:, compare_params:)
    self.local_records = local_records
    self.compare_params = compare_params
  end

  def call
    self.ad_records = AdServiceApi.request(local_records.map(&:external_reference))
    build_verification_results
  end

  private

  def build_verification_results
    local_records.map do |local_record|
      { record: local_record, mismatches: find_mismatches(local_record) }
    end
  end

  def find_mismatches(local_record)
    ad_record = ad_records.find { |r| r['reference'] == local_record.external_reference }
    mismatches = []

    COMPARED_ATTRIBUTES_MAP.select { |k, _v| compare_params.include?(k.to_s) }.each do |local_attr, ad_attr|
      local_value = local_record.public_send(local_attr)
      ad_value = ad_record[ad_attr.to_s]

      unless attribute_matches?(local_attr, local_value, ad_value)
        mismatches << { attr_name: local_attr.to_s,
                        local_value: local_value,
                        ad_value: ad_value }
      end
    end

    mismatches
  end

  def attribute_matches?(attr_name, local_value, ad_value)
    if attr_name == :status
      STATUSES_MAP[local_value.to_sym] == ad_value
    else
      local_value == ad_value
    end
  end
end
