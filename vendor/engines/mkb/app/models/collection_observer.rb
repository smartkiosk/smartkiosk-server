# encoding: utf-8

class CollectionObserver < ActiveRecord::Observer
  def after_create(collection)
    return if collection.terminal_id.blank?

    CoreBanking::Incassation.create! attributes(collection)
  end

  def after_update(collection)
    return if collection.terminal_id.blank?

    entry   = CoreBanking::Incassation.where(:IncassID => collection.id).first
    entry ||= CoreBanking::Incassation.new

    entry.assign_attributes attributes(collection)
    entry.save!
  end

  def attributes(collection)
    notes = collection.banknotes.map{|k,v| "v[0,RUB]=(#{k}:#{v})"}.join(';') + ';'

    return {
      :incassid             => collection.id,
      :terminalid           => collection.terminal_id,
      :eventdatetime        => collection.collected_at,
      :serverdatetime       => collection.created_at,
      :amount               => collection.cash_sum,
      :monitoringamount     => collection.payments_sum,
      :fullmonitoringamount => collection.approved_payments_sum,
      :printamount          => collection.receipts_sum || 0,
      :notedata             => notes.blank? ? '--' : notes,
      :flags                => collection.reset_counters ? 0 : 1,
      :barcode              => "--",
      :fiscalmemoryamount   => 0,
      :currencycode         => 643
    }
  end
end