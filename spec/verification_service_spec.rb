# frozen_string_literal: true

require_relative '../lib/verification_service'
require_relative '../lib/campaign'

RSpec.describe VerificationService do
  let(:campaigns) do
    [Campaign.new(id: 2, job_id: 2, status: 'paused', external_reference: '2', ad_description: 'desc'),
     Campaign.new(id: 3, job_id: 3, status: 'disabled', external_reference: '3', ad_description: 'desc')]
  end

  let(:ad_service_return) do
    [{"reference"=>"2", "status"=>"disabled", "description"=>"Description for campaign 12"},
     {"reference"=>"3", "status"=>"enabled", "description"=>"Description for campaign 13"}]
  end

  it 'detects mismatches in status between local campaigns and campaigns from ad service' do
    allow(AdServiceApi).to receive(:request).and_return(ad_service_return)
    verification_results = VerificationService.new(local_records: campaigns, compare_params: %w[status]).call

    expect(verification_results[0][:record]).to eq(campaigns[0])
    expect(verification_results[0][:mismatches]).to be_empty

    expect(verification_results[1][:record]).to eq(campaigns[1])
    expect(verification_results[1][:mismatches]).to eq(
      [{ attr_name: 'status',
         local_value: 'disabled',
         ad_value: 'enabled' }]
    )
  end
end
