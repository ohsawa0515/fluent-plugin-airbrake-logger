class Fluent::AirbrakeLoggerOutput < Fluent::Output
  Fluent::Plugin.register_output('airbrake_logger', self)

  LOG_LEVEL_MAP = {
    'CRITICAL' => 50,
    'FATAL'    => 50,
    'ERROR'    => 40,
    'WARNING'  => 30,
    'WARN'     => 30,
    'INFO'     => 20,
    'DEBUG'    => 10
  }

  config_param :api_key, :string, :default => nil
  config_param :host, :string, :default => 'localhost'
  config_param :port, :integer, :default => '80'
  # +true+ for https connections, +false+ for http connections.
  config_param :secure, :bool, :default => true
  # +true+ to use whatever CAs OpenSSL has installed on your system. +false+ to use the ca-bundle.crt file included in Airbrake itself (reccomended and default)
  config_param :use_system_ssl_cert_chain, :bool, :default => true
  # The HTTP open timeout in seconds (defaults to 2).
  config_param :http_open_timeout, :integer, :default => nil
  # The HTTP read timeout in seconds (defaults to 5).
  config_param :http_read_timeout, :integer, :default => nil
  config_param :proxy_host, :string, :default => nil
  config_param :proxy_port, :integer, :default => nil
  config_param :proxy_user, :string, :default => nil
  config_param :proxy_pass, :string, :default => nil
  # defaults to ["password", "password_confirmation"]
  config_param :param_filters, :string, :default => nil
  config_param :development_environments, :string, :default => nil
  config_param :development_lookup, :bool, :default => false
  config_param :environment_name, :string, :default => 'production'
  config_param :project_root, :string, :default => ''
  config_param :notifier_name, :string, :default => nil
  config_param :notifier_version, :string, :default => nil
  config_param :notifier_url, :string, :default => nil
  config_param :user_information, :string, :default => nil
  config_param :user_attributes, :string, :default => nil
  config_param :framework, :string, :default => nil
  config_param :project_id, :string, :default => nil
  config_param :log_level, :string, :default => 'DEBUG'
  config_param :log_path, :string, :default => nil
  config_param :cut_off_char, :integer, :default => 200

  # record parameters
  config_param :log_level_record, :string, :default => 'severity'
  config_param :error_class_record, :string, :default => 'error_class'
  config_param :batcktrace_record, :string, :default => 'error_backtrace'
  config_param :error_message_record, :string, :default => 'error_message'
  config_param :component_record, :string, :default => 'component'
  config_param :action_record, :string, :default => 'action'

  def initialize
    super
    require 'airbrake'
  end

  def configure(conf)
    super

    Airbrake.configure do |config|
      config.host    = @host
      config.port    = @port ? @port : (@secure ? 443 : 80)
      config.secure  = @secure
      config.use_system_ssl_cert_chain = @use_system_ssl_cert_chain
      config.http_open_timeout = @http_open_timeout if @http_open_timeout
      config.http_read_timeout = @http_read_timeout if @http_read_timeout
      config.proxy_host        = @proxy_host
      config.proxy_port        = @proxy_port
      config.proxy_user        = @proxy_user
      config.proxy_pass        = @proxy_pass
      config.param_filters     = @param_filters.split(/\s+/) if @param_filters
      config.development_environments = @development_environments.split(/\s+/) if @development_environments
      config.development_lookup = @development_lookup
      config.environment_name   = @environment_name
      config.project_root       = @project_root
      config.notifier_name      = @notifier_name if @notifier_name
      config.notifier_version   = @notifier_version if @notifier_version
      config.notifier_url       = @notifier_url if @notifier_url
      config.user_information   = @user_information if @user_information
      config.user_attribute     = @user_attribute.split(/s+/) if @user_attribute
      config.framework          = @framework if @framework
      config.project_id         = @project_id
      config.logger             = Logger.new(@log_path) if @log_path
      @aconf = config
    end

    @sender = Airbrake::Sender.new(@aconf)
    @log_level = LOG_LEVEL_MAP[@log_level.upcase]
  end

  def notification_needed(_tag, _time, record)
    severity_map = LOG_LEVEL_MAP[record[@log_level_record].upcase]

    record[@log_level_record] ? severity_map >= @log_level : false
  end

  def build_error_message(record)
    error_message = record[@error_message_record] ? cut_down_message(record[@error_message_record]) :
      (record['message'] ? cut_down_message(record['message']) : 'Notification')
    "[#{record[@log_level_record]}] #{record[@error_class_record]} #{error_message}"
  end

  def cut_down_message(message)
    message.to_s[0, @cut_off_char]
  end

  def build_error_backtrace(record)
    record[@batcktrace_record] ? record[@batcktrace_record] : (record['backtrace'] ? record['backtrace'] : ["nil"])
  end

  def emit(tag, es, chain)
    es.each do |time, record|

      next unless notification_needed(tag, time, record)

      other_record = record.reject {|k, _|
        %W(#{@log_level_record} #{@error_class_record} #{@batcktrace_record}
           #{@error_message_record} #{@component_record} #{@action_record} backtrace).include?(k) }

      @notice  = Airbrake::Notice.new(@aconf.merge(
        :api_key       => @api_key,
        :error_class   => record[@error_class_record],
        :backtrace     => build_error_backtrace(record),
        :error_message => build_error_message(record),
        :hostname      => record['hostname'],
        :component     => record[@component_record],
        :action        => record[@action_record],
        :cgi_data      => other_record
      ))

      @sender.send_to_airbrake(@notice) if @notice
    end
    chain.next
  end
end
