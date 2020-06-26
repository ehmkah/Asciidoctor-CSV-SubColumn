require 'asciidoctor/extensions' unless RUBY_ENGINE == 'opal'
require 'csv'
require 'tempfile'

include Asciidoctor

class CsvSubcolumnIncludeProcessor < Extensions::IncludeProcessor

  #handle target
  def handles? target
    #TODO relative file path handle. current only use absolute path.
    target.end_with? '.csv'
  end

  # process method
  def process doc, reader, target, attributes
    csv_separator = ","

    if attributes.has_key? 'columns' #handle csv with column attributes

      columnNumbers = parse_attributes_columns attributes, ';'

      csv_string = ""
      CSV.foreach(target) do |row|
        columnNumbers.each do |columnNumber|
          csv_string << row[columnNumber]
          csv_string << csv_separator
        end
        csv_string.delete_suffix!(csv_separator)
        csv_string << "\n"
      end

      reader.push_include csv_string, target, target, 1, attributes
      csv_string.clear

    else #handle csv without column attributes
      content = (open target).readlines
      reader.push_include content, target, target, 1, attributes
    end
  end

  #parse attributes. transform columns number to array.
  def parse_attributes_columns attributes, splitter

    #value for columns key in attributes hash list
    colNums_Str = attributes['columns']

    #convert value string to int array
    colNums_Array = colNums_Str.split(splitter).map(&:to_i)

    return colNums_Array
  end

end
