class CashAcquirer
  def initialize(*args)
  end
  
  class Authorization
    def success?
      true
    end

    def confirm

    end

    def reverse

    end
  end

  def authorize(payment)
    Authorization.new
  end
end
