module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module DirecPay
        class Helper < ActiveMerchant::Billing::Integrations::Helper
          mapping :account, 'MID'
          mapping :order, 'Merchant Order No'
          mapping :amount, 'Amount'        
          mapping :currency, 'Currency'
          
          mapping :customer, :email => 'custEmailId'
          
          mapping :billing_address,  :city     => 'custCity',
                                     :address1 => 'custAddress',
                                     :state    => 'custState',
                                     :zip      => 'custPinCode',
                                     :country  => 'custCountry'

          mapping :shipping_address, :city     => 'deliveryCity',
                                     :address1 => 'deliveryAddress',
                                     :state    => 'deliveryState',
                                     :zip      => 'deliveryPinCode',
                                     :country  => 'deliveryCountry'

          mapping :notify_url, ''
          mapping :return_url, ''
          mapping :cancel_return_url, ''
          mapping :description, ''
          mapping :tax, ''
          mapping :shipping, ''
          

          def customer(params = {})
            add_field(mappings[:customer][:email], params[:email])
            add_field('custName', "#{params[:first_name]} #{params[:last_name]}")
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
            params.merge!(:address1 => "#{params[:address1]} #{params[:address2]}")
            super
          end
          
          def billing_address(params = {})
            params.merge!(:address1 => "#{params[:address1]} #{params[:address2]}")
            super
          end
        end
      end
    end
  end
end
