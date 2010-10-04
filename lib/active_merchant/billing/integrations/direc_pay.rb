module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module DirecPay
        autoload :Helper, File.dirname(__FILE__) + '/direc_pay/helper.rb'
        autoload :Common, File.dirname(__FILE__) + '/direc_pay/common.rb'
        autoload :Return, File.dirname(__FILE__) + '/direc_pay/return.rb'
        autoload :Notification, File.dirname(__FILE__) + '/direc_pay/notification.rb'
       
        mattr_accessor :production_url, :test_url
        
        self.production_url = "https://www.timesofmoney.com/direcpay/secure/dpMerchantTransaction.jsp"
        self.test_url       = "https://test.timesofmoney.com/direcpay/secure/dpMerchantTransaction.jsp"

        def self.service_url
          mode = ActiveMerchant::Billing::Base.integration_mode
          case mode
          when :production
            self.production_url    
          when :test
            self.test_url
          else
            raise StandardError, "Integration mode set to an invalid value: #{mode}"
          end
        end
        
        def self.notification(post)
          Notification.new(post)
        end
        
        def self.return(post)
          Return.new(post)
        end
      end
    end
  end
end
