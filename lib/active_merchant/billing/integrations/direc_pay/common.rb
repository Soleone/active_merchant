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
          
          # TODO: maybe remove from Return class
          def amount
            Money.new(gross.to_i * 100, 'INR')
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
  
          def test?
            # no real way to find out from the notification
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
            case status
            when 'Failed'
              "The transaction was refused by the payment server."
            else
              params['Error message']              
            end
          end

          def acknowledge
            true
          end


          # Take the posted data and move the relevant data into a hash
          def parse(post)
            @params = {}
            @raw = post.to_s
            for line in @raw.split('&')    
              key, value = *line.scan( %r{^([A-Za-z0-9_.]+)\=(.*)$} ).flatten
              params[key] = CGI.unescape(value)
            end
            
            values = params['responseparams'].to_s.split('|')
            response_params = values.size == 3 ? ['DirecPay Reference ID', 'Flag', 'Error message'] : RESPONSE_PARAMS
            response_params.each_with_index do |name, index|
              params[name] = values[index]
            end
            params
          end
        end
        
      end
    end
  end
end