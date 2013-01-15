require 'fileutils'

namespace :dump do
  task :providers => :environment do
    FileUtils.mkdir_p root  = Rails.root.join('tmp', 'dump')
    FileUtils.mkdir_p root.join('icons', 'providers')
    FileUtils.mkdir_p root.join('icons', 'provider_groups')

    providers = Provider.all
    provider_groups = ProviderGroup.all

    data = {
      :providers => providers.map{|x|
        {
          :id        => x.id,
          :title     => x.title,
          :keyword   => x.keyword,
          :fields    => x.fields_dump,
          :group_id  => x.provider_group_id
        }
      },
      :provider_groups => provider_groups.map{|x|
        {
          :id        => x.id,
          :title     => x.title,
          :parent_id => x.provider_group_id
        }
      }
    }

    File.open(root.join('data.yml'), 'w') do |f|
      YAML.dump data, f
    end

    providers.each do |p|
      next if p.icon.blank?

      path = p.icon.path
      type = p.icon.path.split('.').last

      FileUtils.cp path, root.join('icons', 'providers', "#{p.keyword}.#{type}")
    end

    provider_groups.each do |pg|
      next if pg.icon.blank?

      path = pg.icon.path
      type = pg.icon.path.split('.').last

      FileUtils.cp path, root.join('icons', 'provider_groups', "#{pg.keyword}.#{type}")
    end
  end
end