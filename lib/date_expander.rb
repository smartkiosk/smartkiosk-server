module DateExpander extend ActiveSupport::Concern
  included do
    cattr_accessor :date_expander_field
    expand_date_from :created_at

    before_create do
      x = self.class.date_expander_field
      x = self.send(x)

      if self.class.date_expander_field == :created_at && x.blank?
        x = DateTime.now
      end

      unless x.blank?
        self.hour  = x.change(:min => 0)
        self.day   = x.change(:hour => 0).to_date
        self.month = x.change(:day => 1, :hour => 0).to_date
      end
    end

    before_update do
      x = self.class.date_expander_field
      x = self.send(x)

      unless x.blank?
        self.hour  = x.change(:min => 0)
        self.day   = x.change(:hour => 0).to_date
        self.month = x.change(:day => 1, :hour => 0).to_date
      end
    end
  end

  module ClassMethods
    def expand_date_from(field)
      self.date_expander_field = field
    end
  end
end