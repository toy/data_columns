module DataColumns
  def self.included(base)
    base.extend ClassMethods
  end

  def read_data_column(name)
    name = name.to_s
    converter = self.class.data_column_converters[name]
    (self[:data] || {})[name] || converter.default
  end

  def write_data_column(name, value)
    name = name.to_s
    converter = self.class.data_column_converters[name]

    if changed_attributes.include?(name)
      old = changed_attributes[name]
      changed_attributes.delete(name) unless field_changed?(name, old, value)
    else
      old = clone_attribute_value(:read_data_column, name)
      changed_attributes[name] = old if field_changed?(name, old, value)
    end

    self[name] = value

    (self[:data] ||= {})[name] = converter.type_cast(value)
  end

  module ClassMethods
    def data_column_converters
      read_inheritable_attribute(:data_column_converters) || write_inheritable_attribute(:data_column_converters, {})
    end

    def data_column_names
      data_column_converters.keys
    end

    def data_columns(*columns)
      options = columns.extract_options!
      type = options[:type] && options[:type].to_s
      default = options[:default]

      if data_column_converters.empty?
        serialize :data, Hash
        attr_protected :data
        class_eval %Q{
          def self.column_names
            super + data_column_names
          end
        }, __FILE__, __LINE__
      end

      columns.each do |column|
        column = column.to_s
        data_column_converters[column] = ActiveRecord::ConnectionAdapters::Column.new(column, default, type)
        class_eval %Q{
          def #{column}
            read_data_column(:#{column})
          end
          def #{column}=(value)
            write_data_column(:#{column}, value)
          end
        }, __FILE__, __LINE__
      end
    end
  end
end
