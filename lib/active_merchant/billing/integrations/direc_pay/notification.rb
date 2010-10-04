require 'net/http'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module DirecPay
        class Notification < ActiveMerchant::Billing::Integrations::Notification
          include Common
        end
      end
    end
  end
end
