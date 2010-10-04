module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module DirecPay
        
        module Common
          RESPONSE_PARAMS = ['DirecPay Reference ID', 'Flag', 'Country', 'Currency', 'Other Details', 'Merchant Order No', 'Amount']

          def success?
            complete?
          end
          
          def complete?
            status == 'Completed'
          end 

          def item_id
            params['Merchant Order No']
          end

          def transaction_id
            params['DirecPay Reference ID']
          end

          # the money amount we received in X.2 decimal
          def gross
            params['Amount']
          end

          def currency
            params['Currency']
          end
  
          def country
            params['Country']
          end
  
          def other_details
            params['Other Details']
          end
  
          # Was this a test transaction?
          def test?
            transaction_id == '200904281000001'
          end

          def status
            case params['Flag']
            when 'SUCCESS'
              'Completed'
            when /Transaction Booked/i
              'Pending'
            when 'FAIL'
              'Failed'
            else
              'Error'
            end
          end

          def message
            params['Error message']
          end

          def acknowledge
            true
          end


          private

          # Take the posted data and move the relevant data into a hash
          def parse(post)
            super            
            values = params['responseparams'].to_s.split('|')
            response_params = values.size == 3 ? ['DirecPay Reference ID', 'Flag', 'Error message'] : RESPONSE_PARAMS
            response_params.each_with_index do |name, index|
              params[name] = values[index]
            end
          end
        end
        
      end
    end
  end
end