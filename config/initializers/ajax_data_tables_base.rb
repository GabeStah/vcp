module AjaxDatatablesRails
  class Base
    extend Forwardable

    def search_condition(column, value)
      model, column = column.split('.')
      model = model.singularize.titleize.gsub( / /, '' ).constantize
      casted_column = ::Arel::Nodes::NamedFunction.new('CAST', [model.arel_table[column.to_sym].as(ActiveRecord::Base::connection.to_s.include?('Mysql2Adapter') ? 'CHAR' : 'VARCHAR')])
      casted_column.matches("%#{value}%")
    end
  end
end