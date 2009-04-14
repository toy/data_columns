module DataColumns
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def data_column_names
      read_inheritable_attribute(:data_column_names) || write_inheritable_attribute(:data_column_names, [])
    end

    def data_columns(*columns)
      if data_column_names.empty?
        serialize :data, Hash
        attr_protected :data
        class_eval %Q{
          def self.column_names
            super + data_column_names
          end
        }, __FILE__, __LINE__
      end

      columns.each do |column|
        data_column_names << column.to_s
        class_eval %Q{
          def #{column}
            (self[:data] || {})[:#{column}]
          end
          def #{column}=(value)
            (self[:data] ||= {})[:#{column}] = value
          end
        }, __FILE__, __LINE__
        # write_attribute(:#{column}, value)
      end
    end
  end
end
