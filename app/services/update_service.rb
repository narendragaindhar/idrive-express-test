class UpdateService
  include HTTParty
  attr_accessor :product

  def self.perform(order_state)
    updater = if order_state.order.order_type.product.is? :ibackup
                IBackupUpdateService.new(order_state)
              elsif order_state.order.order_type.product.is? :idrive360
                IDrive360UpdateService.new(order_state)
              else
                IDriveUpdateService.new(order_state)
              end

    if updater.enabled?
      updater.perform
    else
      Rails.logger.warn "API update currently disabled for #{updater.product}"
      true
    end
  end

  def initialize(order_state, proxy_url: ENV.fetch('FIXIE_URL', ''))
    @order_state = order_state
    @product = order_state.order.order_type.product.name

    proxy = URI(proxy_url)
    return unless proxy.host

    Rails.logger.debug "Updating #{product} API using proxy. proxy_host=#{proxy.host}"
    self.class.http_proxy(proxy.host, proxy.port, proxy.user, proxy.password)
  end

  def perform
    begin
      response = self.class.post(url, body: request_body, headers: auth_headers, timeout: 5)
      return true if response.code == 200

      Rails.logger.error "#{product} API returned an error. "\
                         "response_code=#{response.code} "\
                         "response_headers=#{response.headers.inspect} "\
                         "response_body=\"#{response.body}\" "\
                         "request_body=#{request_body.inspect}"
    rescue StandardError => e
      Rails.logger.error "An exception occurred durng the #{product} API "\
                         "update: request_body=#{request_body.inspect} "\
                         "exception=\"#{e.inspect}\""
    end
    false
  end

  def enabled?
    raise NotImplementedError, 'Method must be overridden in subclass: enabled?()'
  end

  private

  def url
    raise NotImplementedError, 'Method must be overridden in subclass: url()'
  end

  def auth_token
    raise NotImplementedError, 'Method must be overridden in subclass: auth_token()'
  end

  def auth_headers
    { 'Authorization' => "Token token=#{auth_token}" }
  end

  def request_body
    {
      order_id: @order_state.order_id,
      description: @order_state.comments,
      percentage: @order_state.state.percentage
    }
  end
end
