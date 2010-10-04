require 'test_helper'

class DirecPayTest < Test::Unit::TestCase
  def setup
    @merchant_id = '200904281000001'
    @authorization = '1001010000026680'
    @notification_url = "http://pingme.heroku.com"
    @gateway = DirecPayGateway.new(:login => @merchant_id, :test => false)    
  end
  
  def test_request_transaction_status    
    params = [@authorization, @merchant_id, @notification_url].join('|')
    @gateway.expects(:ssl_get).with(DirecPayGateway::TEST_URL + "?requestparams=#{CGI.escape(params)}")
    
    @gateway.request_transaction_status(@authorization, @notification_url)
  end
end
