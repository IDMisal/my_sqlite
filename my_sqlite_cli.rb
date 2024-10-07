require_relative 'my_sqlite_request'
require 'readline'
require 'csv'

def parse_query(query)
  tokens = query.split
  command = tokens.first.upcase

  case command
  when 'SELECT'
    parse_select_query(tokens)
  when 'INSERT'
    parse_insert_query(tokens)
  when 'UPDATE'
    parse_update_query(tokens)
  when 'DELETE'
    parse_delete_query(tokens)
  else
    puts "Invalid query"
  end
end

def parse_select_query(tokens)
  table_index = tokens.index('FROM') + 1
  table_name = tokens[table_index]
  columns = tokens[1..(table_index - 2)].join(' ')
  columns = columns == '*' ? ['*'] : columns.split(',')

  request = MySqliteRequest.new.from(table_name).select(*columns)

  if tokens.include?('WHERE')
    where_index = tokens.index('WHERE')
    column = tokens[where_index + 1]
    value = tokens[(where_index + 3)..-1].join(' ').tr('\'', '')
    request = request.where(column, value)
  end

  if tokens.include?('ORDER')
    order_index = tokens.index('ORDER') + 2
    column = tokens[order_index]
    order = tokens[order_index - 1].downcase.to_sym
    request = request.order(order, column)
  end

   request.run.inspect
end

def parse_insert_query(tokens)
  table_index = tokens.index('INTO') + 1
  table_name = tokens[table_index]
  values_index = tokens.index('VALUES')
  if values_index.nil?
    raise "VALUES keyword not found in INSERT query"
  end
  values_str = tokens[(values_index + 1)..-1].join(' ')
  values = values_str.match(/\((.*)\)/)[1].split(',').map(&:strip)

  columns = read_csv_headers(table_name)
  data = Hash[columns.zip(values)]

  request = MySqliteRequest.new.insert(table_name).values(data)
  request.run
end

def read_csv_headers(table_name)
  CSV.open(table_name, 'r') { |csv| return csv.first }
end

def parse_update_query(tokens)
  puts "Debug: Tokens - #{tokens.inspect}"
  
  table_name = tokens[1]
  set_index = tokens.index('SET')
  where_index = tokens.index('WHERE')

  puts "Debug: set_index - #{set_index}, where_index - #{where_index}"
  
  if where_index
    set_data_str = tokens[(set_index + 1)...where_index].join(' ')
  else
    set_data_str = tokens[(set_index + 1)..-1].join(' ')
  end

  puts "Debug: set_data_str - #{set_data_str}"

  set_data = Hash[set_data_str.split(',').map { |pair| pair.split('=').map(&:strip).map { |s| s.tr('\'', '') } }]

  puts "Debug: set_data - #{set_data}"

  request = MySqliteRequest.new.update(table_name).set(set_data)

  if where_index
    column = tokens[where_index + 1]
    value_tokens = tokens[(where_index + 3)..-1]
    value = value_tokens.join(' ')
    if value.start_with?("'") && value.end_with?("'")
      value = value[1..-2] # Remove the surrounding quotes
    end

    puts "Debug: column - #{column}, value - #{value}"

    request = request.where(column, value)
  end

  request.run
end

def parse_delete_query(tokens)
  table_index = tokens.index('FROM') + 1
  table_name = tokens[table_index]

  request = MySqliteRequest.new.delete.from(table_name)

  if tokens.include?('WHERE')
    where_index = tokens.index('WHERE')
    column = tokens[where_index + 1]
    value = tokens[(where_index + 3)..-1].join(' ').tr('\'', '')
    request = request.where(column, value)
  end

  request.run
end

# def parse_delete_query(tokens)
#     table_index = tokens.index('FROM') + 1
#     table_name = tokens[table_index]
    
#     request = MySqliteRequest.new.delete.from(table_name)
    
#     if tokens.include?('WHERE')
#         where_index = tokens.index('WHERE')
#         column = tokens[where_index + 1]
#         value_tokens = tokens[(where_index + 3)..-1]
#         value = value_tokens.join(' ')
#         if value.start_with?("'") && value.end_with?("'")
#         value = value[1..-2] # Remove the surrounding quotes
#         end
#         request = request.where(column, value)
#     end
    
#     request.run
#     end
      
# Main CLI loop
puts "MySQLite version 0.1 #{Time.now.strftime("%Y-%m-%d")}"

while line = Readline.readline('my_sqlite_cli> ', true)
  break if line.strip == 'quit'
  begin
    parse_query(line.strip)
  rescue StandardError => e
    puts "Error: #{e.message}"
  end
end