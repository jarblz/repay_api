require 'test_helper'
require 'vcr'
VCR.configure do |config|
  config.cassette_library_dir = "test/fixtures/vcr_cassettes"
end

class RepayTest < ActiveSupport::TestCase
  test "truth" do
    assert_kind_of Module, Repay
  end

  test "aquire ach_token" do
    VCR.use_cassette('repay/form_id_request', :allow_playback_repeats => true) do
      VCR.use_cassette('repay/paytoken_request', :allow_playback_repeats => true) do
        VCR.use_cassette('repay/vault_token_request', :allow_playback_repeats => true) do
          customer_id = "123"
          account_holder = "Jerry Smith"
          account_number = "00000000000000"
          routing_number = "121202221"
          assert_not_nil(Repay::AchToken.new(customer_id, account_holder, routing_number, account_number).ach_token)
        end
      end
    end

  end
end
