module ReportBuilder
  def self.constantize(keyword)
    "#{keyword.camelize}Report".constantize rescue false
  end

  class Base
    attr_accessor :report
    attr_accessor :template

    def self.requires_dates!
      @requires_dates = true
    end

    def self.requires_dates?
      !!@requires_dates
    end

    def requires_dates?
      self.class.requires_dates?
    end

    def initialize(report=nil)
      unless report.blank?
        self.report   = report
        self.template = report.report_template
      end
    end

    def keyword
      self.class.name.underscore.gsub('_report', '')
    end

    def arelize(field)
      field = field.split('.')
      table = tables[field.first]

      raise "Table `#{field.first}' not found for `#{template.kind}' report kind" if table.blank?

      table[field.last.to_sym]
    end

    def query
      query = context(report.start, report.finish)

      aggregate = {
        'postgresql' => 'MIN'
      }[ActiveRecord::Base.configurations[Rails.env]['adapter']]

      fields = template.fields.each_with_index do |field, i|
        projection = arelize(field)

        if !aggregate.blank? && !template.groupping.blank?
          projection = Arel::Nodes::NamedFunction.new(
            aggregate, [ projection ]
          )
        end

        projection = projection.as("\"_#{i}\"")
        query = query.project(projection)
      end

      order = arelize(template.sorting) unless template.sorting.blank?
      order = order.desc if !order.blank? && template.sort_desc
      query = query.group(arelize template.groupping) unless template.groupping.blank?
      query = query.order(order) unless order.blank?

      unless template.conditions.blank?
        template.conditions.each do |column, value|
          next if value.blank?

          if value.is_a?(Array)
            query = query.where(arelize(column).in(value))
          else
            query = query.where(arelize(column).eq(value))
          end
        end
      end

      unless template.calculations.blank?
        template.calculations.select{|x| !x.blank?}.each do |calculation|
          query = calculations[calculation].call(query, template)
        end
      end

      query.to_sql
    end

    def human_field_name(field)
      model, name = field.split '.'
      title       = []

      title << I18n.t("activerecord.models.#{model}", :count => 1)
      title << I18n.t("activerecord.attributes.#{model}.#{name}")

      title.join(': ')
    end

    def human_calculation_name(field)
      I18n.t "smartkiosk.reports.data.#{keyword}.calculations.#{field}"
    end

    def human_condition_name(field)
      I18n.t "smartkiosk.reports.data.#{keyword}.conditions.#{field}"
    end

    def human_groupping_names
      groupping.map{|x| [human_field_name(x), x]}
    end

    def human_groupping_field_names(groupping)
      fields[groupping].map{|x| [human_field_name(x), x]}
    end

    def human_calculation_names
      calculations.keys.map{|x| [human_calculation_name(x), x]}
    end

    def human_condition_values(condition)
      conditions[condition].call().with_indifferent_access
    end
  end
end