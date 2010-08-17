require 'test_helper'

class DirecPayHelperTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations
  
  def setup
    @helper = DirecPay::Helper.new('#1234', 'account id', :amount => 500, :currency => 'INR')
  end
 
  def test_basic_helper_fields
    assert_field 'MID', 'account id'
    assert_field 'Merchant Order No', '#1234'

    assert_field 'Amount', '5.00'
    assert_field 'Currency', 'INR'
    assert_field 'Country', 'IND'
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
  
  def test_address_with_a_single_street_address_field
    @helper.billing_address :address1 => "1 My Street"
    @helper.shipping_address :address1 => "1 My Street"    
    assert_field "custAddress", "1 My Street"
    assert_field "deliveryAddress", "1 My Street"    
  end
  
  def test_phone_number_mapping
    @helper.billing_address :phone => "+91 022 28000000"
    
    assert_field 'custPhoneNo1', '91'
    assert_field 'custPhoneNo2', '022'
    assert_field 'custPhoneNo3', '28000000'        
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
  
  def test_generate_request_parameter
    fill_in_transaction_details!(@helper)
    
    transaction_params = ['account id', 'DOM', 'IND', 'INR', '5.00', "#1234", 'NULL', "http://localhost/return", "http://localhost/cancel", "TOML"]
    @helper.expects(:encode_value).with(transaction_params.join('|'))

    @helper.generate_request_parameter
  end
  
  def test_parameters_do_not_contain_special_characters
    fill_in_transaction_details!(@helper)
    
  end
  
  
  def test_exported_form_fields
    fill_in_transaction_details!(@helper)
    
    exported_fields = [
      "custAddress",
      "custCity",
      "custCountry",
      "custEmailId",
      "custMobileNo",
      "custName",
      "custPhoneNo1",
      "custPhoneNo2",
      "custPhoneNo3",
      "custPinCode",
      "custState",
      "deliveryAddress",
      "deliveryCity",
      "deliveryCountry",
      "deliveryMobileNo",
      "deliveryName",
      "deliveryPhNo1",
      "deliveryPhNo2",
      "deliveryPhNo3",
      "deliveryPinCode",
      "deliveryState",
      "editAllowed",
      "otherNotes",
      "requestparameter"
    ]
    assert_equal exported_fields, @helper.form_fields.keys.sort
  end
  
  def test_delete_ME
    encoded = "TVRqQXdPVEEwTWpneE1EQXdNREF4ZkVSUFRYeEpUa1I4U1U1U2ZEVTRMakF3ZkRJeWZFNVZURXg4YUhSMApjRG92TDJ4dlkyRnNhRzl6ZERvek1EQXdMMjl5WkdWeWN5OHhMMlZrTlRJek1EWTVObUZrTlRJMVlqbGwKTXpJeVlUWmhOalJpTlRZek1qSmxMMlJ2Ym1VL2RYUnRYMjV2YjNabGNuSnBaR1U5TVh4b2RIUndPaTh2CmFHRnlaR052Y21WbllXMWxjaTVzYjJOaGJHaHZjM1E2TXpBd01IeFVUMDFN"
    puts @helper.send(:decode_value, encoded)
  end
  
  private
  
  def fill_in_transaction_details!(helper)
    helper.customer :first_name => 'Carl', :last_name => 'Carlton', :email => 'carlton@example.com'
    helper.description = "blabla"

    indian_address = address(:country => "India", :phone => "9122028000000", :phone2 => '+1 613 123 4567')
    helper.shipping_address(indian_address)
    helper.billing_address(indian_address)

    helper.return_url = "http://localhost/return"
    helper.cancel_return_url = "http://localhost/cancel"
  end
end
