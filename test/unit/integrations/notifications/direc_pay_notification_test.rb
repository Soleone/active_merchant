require 'test_helper'

class DirecPayNotificationTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations

  def setup
    @direc_pay = DirecPay::Notification.new(http_raw_data)
  end

  def test_accessors
    assert @direc_pay.complete?
    assert_equal "", @direc_pay.status
    assert_equal "", @direc_pay.transaction_id
    assert_equal "", @direc_pay.item_id
    assert_equal "", @direc_pay.gross
    assert_equal "", @direc_pay.currency
    assert_equal "", @direc_pay.received_at
    assert @direc_pay.test?
  end

  def test_compositions
    assert_equal Money.new(3166, 'USD'), @direc_pay.amount
  end

  # Replace with real successful acknowledgement code
  def test_acknowledgement    

  end

  def test_send_acknowledgement
  end

  def test_respond_to_acknowledge
    assert @direc_pay.respond_to?(:acknowledge)
  end

  private
  def http_raw_data
    ""
  end  
end
