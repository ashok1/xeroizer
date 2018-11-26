module Xeroizer
  class << self
    attr_accessor :xero_config
  end

  def self.configure
    self.xero_config ||= Configuration.new
    yield(xero_config) 
  end

  def self.mock?
    self.xero_config && self.xero_config.mock
  end

  def self.api_config
    {
          :xero_url         => 'https://api.xero.com/api.xro/2.0',
          :site             => 'https://api.xero.com',
          :authorize_url    => 'https://api.xero.com/oauth/Authorize',
          :signature_method => self.mock? ? nil : 'RSA-SHA1' # Skip signature check if mock is true
        }
  end

  class Configuration
    attr_accessor :mock

    def initialize
      @mock = false
    end
  end
end