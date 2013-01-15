module DPS
  module ParamsExporter extend self
    def export(payment)
      params = {}

      if payment.payment_type == ::Payment::TYPE_INNER_CARD
        params[:CARD_ISSUER] = 'FRIENDLY'
      elsif payment.payment_type == ::Payment::TYPE_FOREIGN_CARD
        params[:CARD_ISSUER] = 'ALIEN'
      end

      if payment.cashless?
        keyword = payment.gateway.keyword == '' ? :CARD : :CARD_NUMBER
        params[keyword] = payment.card_number
      end

      if payment.mkb? && !payment.meta[:mkb][:ibank_transaction_id].blank?
        params[:trm_id] = payment.meta[:mkb][:ibank_transaction_id]
      end

      if respond_to?(payment.gateway.keyword)
        params.merge! send(payment.gateway.keyword, payment)
      end

      params = params.map{|k,v| "#{k}=#{v}"}.join("\\n")
    end

    def mts(payment)
      {
        :NUMBER         => payment.account,
        :ESPP_SESSION   => payment.gateway_payment_id,
        :ESPP_OPCODE    => (payment.meta[:gateway][:setting_agent] rescue nil),
        :ESPP_OPNAME    => payment.provider.title,
        :ESPP_LS        => (payment.meta[:gateway][:setting_contract] rescue nil),
        :DPS_SESSION    => (payment.meta[:mkb][:session_number] rescue nil) || payment.session_id,
        :RECEIPT_NUMBER => payment.receipt_number,
        :ESPP_DATE      => (payment.meta[:gateway][:paid_at] rescue nil) || payment.paid_at
      }
    end

    def osmp(payment)
      { :NUMBER => payment.account }
    end

    def megafon(payment)
      { :NUMBER => payment.account }
    end

    def beeline(payment)
      { :NUMBER => payment.account, :TRANSID => '' }
    end

    def yota(payment)
      { :NUMBER => payment.gateway_provider_id, :ACCOUNT => payment.account, :TRANSID => '' }
    end

    def yamoney(payment)
      { :NUMBER => payment.account }
    end

    def skylink(payment)
      { :NUMBER => payment.account }
    end

    def webmoney(payment)
      { :ACCOUNT => payment.fields['purse'], :NUMBER => payment.fields['phone'] }
    end

    def akado(payment)
      { :ACCOUNT => payment.account }
    end

    def matrix(payment)
      { :NUMBER => payment.account }
    end

    def cyberplat(payment)
      { :NUMBER => payment.account }
    end

    def mailru(payment)
      { :NUMBER => payment.account }
    end

    def rapida(payment)
      { :TRANSID => '' }
    end

    def mkb_housing(payment)
      { :TRANSID => '' }
    end

    def mkb_credits(payment)
      {
        :PAY_METHOD   => (payment.cashless? ? 'NONCASH' : 'CASH'),
        :CURRENCY     => payment.fields['currency'],
        :CARD         => payment.fields['card'],
        :ACCOUNT_TO   => payment.fields['account'],
        :KEEP_PAYMENT => 1
      }
    end

    def unistream(payment)
      {
        :SENDER_NUMBER => payment.fields['sender_phone'],
        :SENDER_FIRST_NAME => payment.fields['sender_first_name'],
        :SENDER_LAST_NAME => payment.fields['sender_last_name'],
        :SENDER_MIDDLE_NAME => payment.fields['sender_middle_name'],
        :RECIPIENT_BANK_ID => payment.fields['recipient_bank_id'],
        :RECIPIENT_CURRENCY_ID => payment.fields['recipient_currency_id'],
        :RECIPIENT_NUMBER => payment.fields['recipient_phone'],
        :RECIPIENT_FIRST_NAME => payment.fields['recipient_first_name'],
        :RECIPIENT_LAST_NAME => payment.fields['recipient_last_name'],
        :RECIPIENT_MIDDLE_NAME => payment.fields['recipient_middle_name'],
        :CITIZENSHIP => payment.fields['citizenship'],
        :AMOUNT_VALUE => payment.fields['paid_amount'],
        :CARD => payment.fields['card'],
        :CONTROL_NUMBER => payment.fields['control_number'],
        :FEE => payment.fields['commission_amount'],
        :PAIDOUT => payment.fields['enrolled_amount']
      }
    end

    def mkb_balances(payment)
      { :NUMBER => payment.account, :TRANSID => "" }
    end

    def capstroy_phone(payment)
      { :NUMBER => payment.account }
    end

    def capstroy_internet(payment)
      { :NUMBER => payment.account }
    end

    def northnet(payment)
      { :NUMBER => payment.account }
    end

    def onlime(payment)
      { :NUMBER => payment.account }
    end

    def twokom(payment)
      { :NUMBER => payment.account, :ACCOUNT => 1 }
    end

    def netbynet(payment)
      { :NUMBER => payment.account }
    end

    def handy(payment)
      { 
        :NUMBER  => payment.fields['account'],
        :ACCOUNT => payment.fields['correspondent_account'],
        :PHONE   => payment.fields['phone']
      }
    end

    def mkb_bti(payment)
      {
        :ORDER_NUMBER => payment.fields['number'],
        :YEAR         => payment.fields['year']
      }
    end

    def mkb_cards(payment)
      {
        :CARD_NUMBER  => payment.fields['card'],
        :CARD_SESSION => payment.fields['session']
      }
    end

    def telekom_mpk(payment)
      { :NUMBER => payment.account }
    end

    def moneta_ru(payment)
      { :NUMBER => payment.account }
    end

    def avk_computer(payment)
      { :NUMBER => payment.account }
    end
  end
end