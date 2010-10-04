module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module DirecPay
        
        class Return < ActiveMerchant::Billing::Integrations::Return
          RESPONSE_PARAMS = [ 'DirecPay Reference ID', 'Flag', 'Country', 'Currency', 'Other Details', 'Merchant Order No', 'Amount' ]
          
          def success?
            params['Flag'] == 'SUCCESS'
          end
          
          def parse(post)
            super            
            values = params['responseparams'].to_s.split('|')
            RESPONSE_PARAMS.each_with_index do |name, index|
              params[name] = values[index]
            end
          end
        end
        
      end
    end
  end
end
