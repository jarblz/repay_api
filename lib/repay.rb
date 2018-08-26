require 'rest-client'
require 'repay/version'
require 'repay/ach_token'
require 'repay/ach_token_payment'

module Repay
  FORM_ID_PARAMS = {
    "payment_method"=> "ach",
    "StorePayment"=> "true"
  }
end
