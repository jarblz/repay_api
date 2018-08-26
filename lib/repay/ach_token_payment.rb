module Repay
  class AchTokenPayment
    def initialize token, amount, customer_id
      @token = token
      @amount = amount
      @customer_id = customer_id
      @session_params ||= {
        "amount" => "0.00",
        "customer_id" => "#{@customer_id}",
        "transaction_type" => "sale"
      }
    end

    def checkout_form_id
      # we don't think this changes, but its less brittle if we fetch it every time
      @form_id_request ||= RestClient.post FORM_ID_EP, FORM_ID_PARAMS.to_json, { :content_type => "application/json"}.merge(AUTH_HEADER)
      return nil unless @form_id_request.code == 200
      @checkout_form_id ||= JSON.parse(@form_id_request.body)['checkout_form_id']
    end


    def session_token
      #this is basically a mutex, if someone else makes this request, mine will no longer work for transactions
      return nil unless checkout_form_id
      url = "#{ENV['REPAY_REST_BASE']}/checkout/merchant/api/v1/checkout-forms/#{checkout_form_id}/paytoken"
      @session_request ||= RestClient.post url, @session_params.to_json, { :content_type => "application/json"}.merge(AUTH_HEADER)
      return nil if @session_request.code != 200
      @session_token ||= JSON.parse(@session_request.body)["paytoken"]
    end

    def ach_token
      #this (hopefully) gives us a token we can use indefinitely to pull/post payments
      return nil unless session_token
      url = "#{ENV['REPAY_REST_BASE']}/checkout/merchant/api/v1/checkout-forms/#{checkout_form_id}/token-payment"
      @ach_request ||= RestClient.post url, token_params(session_token).to_json, { :content_type => "application/json"}.merge(AUTH_HEADER)
      return nil if @ach_request.code != 200
      @ach_token ||= JSON.parse(@ach_request.body)["saved_payment_method"]["token"]
    end

    def token_params(session)
      @token_params ||= {
        "amount" => "0.00", #must be this amount for testing purposes
        "name_on_check" => "#{@account_holder}",
        "ach_account_number" => "#{@account_number}",
        "ach_routing_number" => "#{@routing_number}",
        "customer_id" => "#{@customer_id}",
        "transaction_type" => "sale",
        "save_payment_method" => "true",
        "paytoken" => "#{session}"
      }
    end

  end
end
