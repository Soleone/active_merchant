require 'test_helper'

class DirecPayHelperTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations
  
  def setup
    @helper = DirecPay::Helper.new('order-500','account id', :amount => 500, :currency => 'INR')
  end
 
  def test_basic_helper_fields
    assert_field 'MID', 'account id'
    assert_field 'Merchant Order No', 'order-500'

    assert_field 'Amount', '5.00'
    assert_field 'Currency', 'INR'
  end
  
  def test_customer_fields
    @helper.customer :first_name => 'Cody', :last_name => 'Fauser', :email => 'cody@example.com'
    assert_field 'custName', 'Cody Fauser'
    assert_field 'custEmailId', 'cody@example.com'
  end

  def test_billing_address_mapping
    @helper.billing_address :address1 => '1 My Street',
                            :address2 => 'apartment 8',
                            :city => 'Leeds',
                            :state => 'Yorkshire',
                            :zip => 'LS2 7EE',
                            :country  => 'IN'
   
    assert_field 'custAddress', '1 My Street apartment 8'
    assert_field 'custCity', 'Leeds'
    assert_field 'custState', 'Yorkshire'
    assert_field 'custPinCode', 'LS2 7EE'
    assert_field 'custCountry', 'IN'
  end
  
  def test_shipping_address_mapping
    @helper.shipping_address :address1 => '2 My Street',
                             :address2 => 'apartment 8',
                             :city => 'Leeds',
                             :state => 'Yorkshire',
                             :zip => 'LS2 7EE',
                             :country  => 'IN'
   
    assert_field 'deliveryAddress', '2 My Street apartment 8'
    assert_field 'deliveryCity', 'Leeds'
    assert_field 'deliveryState', 'Yorkshire'
    assert_field 'deliveryPinCode', 'LS2 7EE'
    assert_field 'deliveryCountry', 'IN'
  end
  
  def test_unknown_address_mapping
    @helper.billing_address :farm => 'CA'
    assert_equal 4, @helper.fields.size
  end

  def test_unknown_mapping
    assert_nothing_raised do
      @helper.company_address :address => '500 Dwemthy Fox Road'
    end
  end
  
  def test_setting_invalid_address_field
    fields = @helper.fields.dup
    @helper.billing_address :street => 'My Street'
    assert_equal fields, @helper.fields
  end
end
