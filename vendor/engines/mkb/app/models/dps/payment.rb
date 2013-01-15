# encoding: utf-8
class DPS::Payment < ActiveRecord::Base
  establish_connection "drb"

  self.table_name = 'PreprocessingPayments'
  self.primary_key = 'PaymentId'

  GATEWAYS = {
    1    => 'cyberplat',
    3    => 'osmp',
    7    => 'eport',
    9    => 'bashinform',
    11   => 'anthill',
    12   => 'pskb',
    13   => 'skylink_spb',
    14   => 'tiera',
    15   => 'westcall',
    16   => 'astraoreol',
    17   => 'nw_net',
    18   => 'nevalink',
    20   => 'yournet',
    21   => 'peterstar',
    29   => 'handy',
    30   => 'mts',
    34   => 'qiwi_wallet',
    36   => 'unistream',
    38   => 'mgts_mts',
    50   => 'megafon',
    51   => 'prosto',
    52   => 'sim4fly',
    54   => 'bibdd_spb',
    60   => 'rapida',
    61   => 'rapida2',
    70   => 'credit_pilot',
    80   => 'beeline',
    81   => 'yota',
    82   => 'mkb_credits',
    83   => 'mkb_housing',
    84   => 'yamoney',
    85   => 'skylink',
    87   => 'mgts',
    88   => 'mailru',
    89   => 'mkb_bti',
    91   => 'cyberplat_transfers',
    99   => 'webmoney',
    100  => 'akado',
    101  => 'manual_payments',
    2000 => 'mkb_cards',
    2100 => 'mkb_fails',
    2200 => 'mkb_balances',
    2201 => 'capstroy_phone',
    2202 => 'capstroy_internet',
    2203 => 'zelkom',
    2204 => 'northnet',
    2205 => 'telekom_mpk',
    2206 => 'matrix',
    2207 => 'mailru',
    2208 => 'cyberplat_413',
    2209 => 'mkb_balances_bti',
    2210 => 'onlime',
    2211 => 'moneta_ru',
    2212 => 'twokom',
    2213 => 'avk_computer',
    2214 => 'netbynet',
    9999 => 'dummy'
  } unless defined?(GATEWAYS)

  GATEWAY_NAMES = {
    'megafon'   => 'Мегафон СЗ',
    'mts'       => 'МТС ЕСПП',
    'beeline'   => 'Beeline',
    'yamoney'   => 'Яндекс-деньги',
    'osmp'      => 'Qiwi Кошелек',
    'webmoney'  => 'WebMoney',
    'skylink'   => 'Скайлинк Москва',
    'cyberplat' => '413_',
    'matrix'    => 'Matrix Mobile',
    'mailru'    => 'ИТКМ'
  }

  belongs_to :operator, :foreign_key => 'CyberplatOperatorID'
  belongs_to :terminal, :foreign_key => :TerminalID
  belongs_to :payment_card, :foreign_key => ['TerminalID', 'InitialSessionNumber']

  scope :by_date, proc {|date|
    date   = date.to_date
    start  = date.to_datetime
    finish = start + 1.day - 1.second

    where("[PaymentDateTime] BETWEEN '#{start.strftime("%Y-%m-%dT%H:%M:%S")}' AND '#{finish.strftime("%Y-%m-%dT%H:%M:%S")}'")
  }
  scope :paid, where(:StatusID => 7)
  scope :paid_or_manually, where(:StatusID => [7, 100])

  def gateway(gateways=nil, keys=nil)
    if keys.blank?
      gateway_id = DPS::GatewayKey.where(:KeyID => self.GateKeyID).first.try(:GatewayID)
    else
      gateway_id = keys.select{|x| x.KeyID == self.GateKeyID}.first.try(:GatewayID)
    end

    return nil if gateway_id.blank?

    keyword = GATEWAYS[gateway_id]

    return nil if keyword.blank?

    if gateways.blank?
      Gateway.where(:keyword => keyword).first
    else
      gateways.select{|x| x.keyword == keyword}.first
    end
  end

  def cashless?
    !self.payment_card.try(:CardNumber).blank?
  end

  def to_payment_fields(gateways=nil, keys=nil)
    data = {
      :id => self.PaymentId,
      :terminal_id => (terminal.inner_terminal || terminal.build_inner_terminal!).id,
      :agent_id => (terminal.subdealer.inner_agent || terminal.subdealer.build_inner_agent!).id,
      :foreign_id => self.PaymentId,
      :session_id => self.InitialSessionNumber,
      :provider_id => (operator.inner_provider || operator.build_inner_provider!).id,
      :state => self.StatusID == 7 ? 'paid' : 'error',
      :enrolled_amount => self.Amount,
      :paid_amount => self.AmountAll,
      :commission_amount => self.AmountAll - self.Amount,
      :rebate_amount => 0,
      :source => Payment::SOURCE_IMPORT,
      :created_at => self.InitializeDateTime,
      :updated_at => DateTime.now,
      :paid_at => self.PaymentDateTime,
      :card_number => self.payment_card.try(:CardNumber),
      :card_number_hash => self.payment_card.try(:CardNumberMD5),
      :meta => {
        :mkb => {
          :session_number => self.SessionNumber
        }
      }
    }

    # GATEWAY
    gateway = gateway(gateways, keys)

    unless gateway.blank?
      data[:gateway_id] = gateway.id
      data.deep_merge! DPS::ParamsParser.parse(gateway.keyword, self.Params)
    end

    return data
  end
end