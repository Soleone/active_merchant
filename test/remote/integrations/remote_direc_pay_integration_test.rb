require 'test_helper'

class RemoteDirecPayIntegrationTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations

  def setup
    @helper = DirecPay::Helper.new('#1234', fixtures[:direcpay][:mid], :amount => 500, :currency => 'INR')
    @direcpay = DirecPay::Notification.new('')
  end

  def tear_down
    ActiveMerchant::Billing::Base.integration_mode = :test
  end
  
  def test_something
    assert_equal "https://test.timesofmoney.com/direcpay/secure/dpMerchantTransaction.jsp", DirecPay.service_url
    assert_nothing_raised do
      assert_equal false, @direcpay.acknowledge
    end
  end
  
  def test_valid_sender_always_true
    ActiveMerchant::Billing::Base.integration_mode = :production    
  end
  
  def test_get_response
    @helper.customer :first_name => 'Carl', :last_name => 'Carlton', :email => 'carlton@example.com'
    @helper.description = "blabla"

    indian_address = address(:country => "India", :phone => "9122028000000", :phone2 => '+1 613 123 4567')
    @helper.shipping_address(indian_address)
    @helper.billing_address(indian_address)

    @helper.notify_url = "http://localhost/notify"
    @helper.cancel_return_url = "http://localhost/cancel"
  end
end
