class CollectionImporters::DPSWorker
  include Sidekiq::Worker

  def perform(date, page_size=20000)
    incassations = DPS::Incassation.by_date(date)
    pages        = (incassations.count.to_f / page_size.to_f).ceil

    pages.times do |p|
      incassations_slice = incassations.offset(p*page_size).limit(page_size)

      incassation_ids = incassations_slice.map{|x| x.IncassID}
      clones          = []

      incassation_ids.each_slice(1000).to_a.each do |x|
        clones += Collection.where(:source => Collection::SOURCE_IMPORT, :foreign_id => x).select(:foreign_id).map{|x| x.foreign_id}
      end

      record_timestamps = ActiveRecord::Base.record_timestamps

      begin
        while incassation = incassations_slice.pop do
          next if clones.include?(incassation.IncassID)

          fields = incassation.to_collection_fields

          ActiveRecord::Base.record_timestamps = false
          collection    = Collection.new(fields)
          collection.id = fields[:id]
          collection.save(validate: false)
          ActiveRecord::Base.record_timestamps = record_timestamps
        end
      ensure
        ActiveRecord::Base.record_timestamps = record_timestamps
      end
    end
  end
end