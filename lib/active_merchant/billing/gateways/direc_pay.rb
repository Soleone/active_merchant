module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class DirecPayGateway < Gateway      
      TEST_URL = 'https://test.timesofmoney.com/direcpay/secure/dpPullMerchAtrnDtls.jsp'
      LIVE_URL = 'https://www.timesofmoney.com/direcpay/secure/dpPullMerchAtrnDtls.jsp'
      
      # The countries the gateway supports merchants from as 2 digit ISO country codes
      self.supported_countries = [ 'IN' ]
      
      # The card types supported by the payment gateway
      self.supported_cardtypes = []
      
      # The homepage URL of the gateway
      self.homepage_url = 'http://www.timesofmoney.com/direcpay/jsp/home.jsp'
      
      # The name of the gateway
      self.display_name = 'DirecPay'
      
      def initialize(options = {})
        requires!(options, :login)
        @options = options
        super
      end  
    
      def request_transaction_status(authorization, notification_url)
        parameters = [ authorization, @options[:login], notification_url ]
        
        commit(parameters)
      end
      
      def test?
        @options[:test] || super
      end
      
      
      private
      
      def commit(parameters)
        url = test? ? TEST_URL : LIVE_URL
        response = ssl_get("#{url}?#{post_data(parameters)}")
      end
      
      def post_data(parameters)
        data = PostData.new
        data[:requestparams] = parameters.join('|')
        data.to_post_data
      end
    end
  end
end

