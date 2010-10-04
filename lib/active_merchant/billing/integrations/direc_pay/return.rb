module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module DirecPay
        
        class Return < ActiveMerchant::Billing::Integrations::Return
          include Common          
        end
        
      end
    end
  end
end
