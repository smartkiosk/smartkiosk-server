class ISO8583MKBAcquirer
  class << self
    attr_reader :gateway

    def ensure_running(config)
      if @gateway.nil?
        if !ISO8583::MKB::Logging.started?
          ISO8583::MKB::Logging.start Rails.root.join('log/iso8583_mkb.log')
        end

        @gateway = ISO8583::MKB::SynchronousGateway.new(config)
      end
    end

    def stop
      @gateway.stop unless @gateway.nil?
      @gateway = nil
      ISO8583::MKB::Logging.stop
    end
  end

  class Authorization
    def initialize(auth)
      @auth = auth
    end

    def success?
      @auth.success?
    end

    def error
      @auth.status_description
    end

    def confirm

    end

    def reverse
      reversal = @auth.reverse
      # TODO: set reason code

      ISO8583MKBAcquirer.gateway.execute reversal
      # TODO: possibly report failure
    end
  end

  def initialize
    # TODO: load from config file
    @config = {
      :dhi              => 'tcp://127.0.0.1:2222',
      :processing_code  => "00000000",
      :merchant_type    => "4814",
      :acquirer_country => "643",
      :entry_mode       => "9010",
      :condition_code   => "00",
      :acquirer         => "443222",
      :terminal_id      => "49990001",
      :acceptor_id      => "510000000000016"
    }
    ISO8583MKBAcquirer.ensure_running @config
  end

  def authorize(payment)
    auth = ISO8583::MKB::Authorization.new
    auth.processing_code = @config[:processing_code]
    auth.merchant_type = @config[:merchant_type]
    auth.acquirer_country = @config[:acquirer_country]
    auth.entry_mode = @config[:entry_mode]
    auth.condition_code = @config[:condition_code]
    auth.acquirer = @config[:acquirer]
    auth.terminal_id = @config[:terminal_id]
    auth.acceptor_id = @config[:acceptor_id]

    auth.track2 = payment.card_track2

    delimiter = auth.track2.index '='
    auth.pan = auth.track2.slice(0, delimiter)
    auth.expiry = auth.track2.slice(delimiter + 1, 4)

    terminal = "OOOMKB TERM#{payment.terminal.keyword}"
    city = "Moscow"
    country = "RU"

    auth.acceptor_name = sprintf("%-25s%-13s%-2s", terminal, city, country)

    # TODO: implement currency handling
    auth.amount = (payment.paid_amount * 100).to_i
    auth.currency = 643

    # TODO: build additional data
    auth.additional = "USRDT, <cm>#{payment.commission_amount}</cm>, <ses>#{payment.session_id}</ses>backend data"

    ISO8583MKBAcquirer.gateway.execute auth

    Authorization.new auth
  end
end
