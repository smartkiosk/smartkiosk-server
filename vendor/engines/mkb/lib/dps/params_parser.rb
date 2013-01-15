module DPS
  class ParamsParser

    def self.parse(keyword, params)
      params = Hash[
        *params.strip.split("\\n").
          map{|x| x.split("=")}.
          select{|x| x.length > 1}.
          flatten
      ]

      result = {}

      if params['CARD_NUMBER'].blank?
        result[:payment_type] = ::Payment::TYPE_CASH 
      elsif params['CARD_ISSUER'] == 'FRIENDLY'
        result[:payment_type] = ::Payment::TYPE_INNER_CARD
      else
        result[:payment_type] = ::Payment::TYPE_FOREIGN_CARD
      end

      result[:meta] = {:mkb => {}}
      result[:meta][:mkb][:ibank_transaction_id] = params['trm_id'] unless params['trm_id'].blank?

      result.deep_merge! self.send(keyword, params)
      result
    end

    def self.method_missing(method, *args)
      parse_account(args[0])
    end

    def self.mkb_credits(params)
      {
        :fields => {
          'card'     => params['CARD'],
          'account'  => params['ACCOUNT_TO'],
          'currency' => params['CURRENCY']
        }
      }
    end

    def self.mts(params)
      {
        :account => params['NUMBER'],
        :gateway_payment_id => params['ESPP_SESSION'],
        :receipt_number => params['RECEIPT_NUMBER'],
        :meta => {
          :gateway => {
            :setting_agent => params['ESPP_OPCODE'],
            :setting_contract => params['ESPP_LS'],
            :paid_at => params['ESPP_DATE']
          }
        }
      }
    end

    def self.webmoney(params)
      {
        :fields  => {'purse' => params['ACCOUNT'], 'phone' => params['NUMBER']}
      }
    end

    def self.unistream(params)
      {
        :fields => {
          'sender_phone' => params['SENDER_NUMBER'],
          'sender_first_name' => params['SENDER_FIRST_NAME'],
          'sender_last_name' => params['SENDER_LAST_NAME'],
          'sender_middle_name' => params['SENDER_MIDDLE_NAME'],
          'recipient_bank_id' => params['RECIPIENT_BANK_ID'],
          'recipient_currency_id' => params['RECIPIENT_CURRENCY_ID'],
          'recipient_phone' => params['RECIPIENT_NUMBER'],
          'recipient_first_name' => params['RECIPIENT_FIRST_NAME'],
          'recipient_last_name' => params['RECIPIENT_LAST_NAME'],
          'recipient_middle_name' => params['RECIPIENT_MIDDLE_NAME'],
          'citizenship' => params['CITIZENSHIP'],
          'paid_amount' => params['AMOUNT_VALUE'],
          'card' => params['CARD'],
          'control_number' => params['CONTROL_NUMBER'],
          'commission_amount' => params['FEE'],
          'enrolled_amount' => params['PAIDOUT']
        }
      }
    end

    def self.handy(params)
      {
        :fields => {
          'account' => params['NUMBER'],
          'correspondent_account' => params['ACCOUNT'],
          'phone' => params['PHONE']
        }
      }
    end

    def self.mkb_bti(params)
      {
        :fields => {
          'number' => params['ORDER_NUMBER'],
          'year'   => params['ORDER_YEAR']
        }
      }
    end

    def self.mkb_cards(params)
      {
        :fields => {
          'card'    => params['CARD_NUMBER'],
          'session' => params['CARD_SESSION']
        }
      }
    end

  private

    def self.parse_account(params, fields=false)
      {
        :account => params['ACCOUNT'] || params['NUMBER']
      }
    end
  end
end