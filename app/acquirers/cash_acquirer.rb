class CashAcquirer
  def initialize(*args)
  end

  class Transaction
    def initialize(payment)
      @payment = payment
    end

    def id
      0
    end

    def authorize
      true
    end

    def reverse
      true
    end

    def confirm
      true
    end

    def error
      nil
    end
  end

  def transaction(payment, &block)
    yield Transaction.new(payment)
  end
end
