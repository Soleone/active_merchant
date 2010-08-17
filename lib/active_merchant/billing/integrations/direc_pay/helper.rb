require 'base64'

# TODO
# ====
#
#
# QUESTIONS
# =========
# 
# 
# SUGGESTIONS
# ===========
# 
# 
module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module DirecPay
        class Helper < ActiveMerchant::Billing::Integrations::Helper        
          mapping :account,  'MID'
          mapping :order,    'Merchant Order No'
          mapping :amount,   'Amount'        
          mapping :currency, 'Currency'
          mapping :country,  'Country'
          
          mapping :customer, :name  => 'custName',
                             :email => 'custEmailId'
          mapping :billing_address,  :city     => 'custCity',
                                     :address1 => 'custAddress',
                                     :state    => 'custState',
                                     :zip      => 'custPinCode',
                                     :country  => 'custCountry',
                                     :phone2   => 'custMobileNo'

          mapping :shipping_address, :name     => 'deliveryName',
                                     :city     => 'deliveryCity',
                                     :address1 => 'deliveryAddress',
                                     :state    => 'deliveryState',
                                     :zip      => 'deliveryPinCode',
                                     :country  => 'deliveryCountry',
                                     :phone2   => 'deliveryMobileNo'

          # mapping :return_url, ''
          mapping :description, 'otherNotes'
          mapping :edit_allowed, 'editAllowed'
          
          mapping :return_url, 'Success URL'
          mapping :cancel_return_url, 'Failure URL'
          mapping :operating_mode, 'Operating Mode'
          mapping :other_details, 'Other Details'
          mapping :collaborator, 'Collaborator'
          
          OPERATING_MODE = 'DOM'
          COUNTRY        = 'IND'
          CURRENCY       = 'INR'          
          OTHER_DETAILS  = 'NULL'
          EDIT_ALLOWED   = 'N'
          
          ENCODED_PARAMS = [:account, :operating_mode, :country, :currency, :amount, :order, :other_details, :return_url, :cancel_return_url, :collaborator]
          
          def initialize(order, account, options = {})
            super
            collaborator = (ActiveMerchant::Billing::Base.integration_mode == :test || options[:test]) ? 'TOML' : 'DirecPay'
            add_field(mappings[:collaborator], collaborator)
            add_field(mappings[:country], 'IND')
            add_field(mappings[:operating_mode], OPERATING_MODE)
            add_field(mappings[:other_details], OTHER_DETAILS)
            add_field(mappings[:edit_allowed], EDIT_ALLOWED)
          end
          
          def customer(params = {})
            full_name = "#{params[:first_name]} #{params[:last_name]}"
            add_field(mappings[:customer][:name], full_name)
            add_field(mappings[:customer][:email], params[:email])
          end
          
          # Need to format the amount to have 2 decimal places
          def amount=(money)
            cents = money.respond_to?(:cents) ? money.cents : money
            if money.is_a?(String) or cents.to_i <= 0
              raise ArgumentError, 'money amount must be either a Money object or a positive integer in cents.'
            end
            add_field(mappings[:amount], sprintf("%.2f", cents.to_f/100))
          end
          
          def shipping_address(params = {})
            add_street_address!(params)
            super(params.dup)
            add_phone_for!(:shipping_address, params)
          end
          
          def billing_address(params = {})
            add_street_address!(params)            
            super(params.dup)
            add_phone_for!(:billing_address, params)
          end
          
          def form_fields
            add_field('requestparameter', generate_request_parameter)
            fields = @fields.dup
            ENCODED_PARAMS.each do |param|
              fields.delete(mappings[param])
            end
            fields
          end
          
          def generate_request_parameter
            params = ENCODED_PARAMS.map{ |param| fields[mappings[param]] }
            encode_value(params.join('|'))
          end
          
          
          private
          
          def add_street_address!(params)
            address = params[:address1]
            address << " #{params[:address2]}" if params[:address2]
            params.merge!(:address1 => address)
          end
          
          def add_phone_for!(address_type, params)
            address_field = address_type == :billing_address ? 'custPhoneNo' : 'deliveryPhNo'
            
            if params.has_key?(:phone)
              country = fields[mappings[address_type][:country]]
              phone = params[:phone].to_s
              # Whipe all non digits
              phone.gsub!(/\D+/, '')
              
              if country == 'IN' && phone =~ /(91)?(\d{3})(\d{4,})$/
                phone_country_code, phone_area_code, phone_number = $1, $2, $3
                add_field("#{address_field}1", phone_country_code || '91')
                add_field("#{address_field}2", phone_area_code)
                add_field("#{address_field}3", phone_number)
              else
                add_field("#{address_field}3", phone)                
              end
            end
          end
          
          # Special characters are NOT allowed while posting transaction parameters on DirecPay system
          def remove_special_characters(string)
            string.gsub(/[~"'&#%]/, '-')
          end
          
          def encode_value(value)
            encoded = Base64.encode64(value).chomp
            string_to_encode = encoded[0, 1] + "T" + encoded[1, encoded.length]
            Base64.encode64(string_to_encode).chomp
          end
          
          def decode_value(value)
            decoded = Base64.decode64(value)
            string_to_decode = decoded[0, 1] + decoded[2, decoded.length]
            Base64.decode64(string_to_decode)
          end
        end
      end
    end
  end
end
