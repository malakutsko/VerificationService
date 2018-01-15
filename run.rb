# frozen_string_literal: true

require_relative './lib/campaign'
require_relative './lib/verification_service'

records = [
  Campaign.new(id: 1, job_id: 1, status: 'active', external_reference: '1', ad_description: 'desc'),
  Campaign.new(id: 2, job_id: 2, status: 'paused', external_reference: '2', ad_description: 'desc'),
  Campaign.new(id: 3, job_id: 3, status: 'disabled', external_reference: '3', ad_description: 'desc')
]

verification_resutls = VerificationService.new(local_records: records, compare_params: %w[status]).call

mismatched_list = verification_resutls.select { |r| r[:mismatches].any? }

if mismatched_list.empty?
  puts 'The data is verified. No mismatches found'
  return
end

mismatched_list.each do |r|
  puts "Mismatches in campaign #{r[:record].id}:"
  puts r[:mismatches].map { |m| "#{m[:attr_name]}: #{m[:local_value]}/#{m[:ad_value]}" }.join("\n")
end
