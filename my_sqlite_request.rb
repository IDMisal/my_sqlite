require 'csv'

class MySqliteRequest
  def initialize
    @table_name = nil
    @select_columns = []
    @where_conditions = {}
    @join_info = nil
    @order_info = nil
    @operation = nil
    @values = {}
    @set_data = {}
  end

  def from(table_name)
    @table_name = table_name
    self
  end

  def select(*column_names)
    if column_names.flatten.include?('*')
      @select_columns = '*'
    else
      @select_columns = column_names.flatten
    end
    self
  end

  def where(column_name, criteria)
    @where_conditions = { column_name => criteria }
    self
  end

  def join(column_on_db_a, filename_db_b, column_on_db_b)
    @join_info = { column_a: column_on_db_a, file_b: filename_db_b, column_b: column_on_db_b }
    self
  end

  def order(order, column_name)
    @order_info = { order: order, column: column_name }
    self
  end

  def insert(table_name)
    @operation = :insert
    @table_name = table_name
    self
  end

  def values(data)
    @values = data
    self
  end

  def update(table_name)
    @operation = :update
    @table_name = table_name
    self
  end

  def set(data)
    @set_data = data
    self
  end

  def delete
    @operation = :delete
    self
  end

  def run
    case @operation
    when :insert
      run_insert
    when :update
      run_update
    when :delete
      run_delete
    else
      puts run_select
    end
  end

  private

  def run_select
    data = read_csv(@table_name)
    data = filter_data(data)
    data = select_columns(data)
    data = sort_data(data)
    data
  end

  def run_insert
    data = read_csv(@table_name, headers: true)
    headers = data.first.keys
    new_row = headers.map { |header| @values[header] }
    data << CSV::Row.new(headers, new_row)
    write_csv(@table_name, data, headers)
  end

  def run_update
    data = read_csv(@table_name, headers: true).map(&:to_h)
    data.each do |row|
      if row[@where_conditions.keys.first] == @where_conditions.values.first
        @set_data.each { |key, value| row[key] = value }
      end
    end
    headers = data.first.keys
    write_csv(@table_name, data, headers)
  end

  def run_delete
    data = read_csv(@table_name, headers: true).map(&:to_h)
    data.reject! { |row| row[@where_conditions.keys.first] == @where_conditions.values.first }
    headers = data.first.keys
    write_csv(@table_name, data, headers)
  end


  def read_csv(file, headers: true)
    csv_content = CSV.read(file, headers: headers, liberal_parsing: true)
    headers ? csv_content.map(&:to_h) : csv_content
  rescue CSV::MalformedCSVError => e
    puts "Error reading CSV file: #{e.message}"
    []
  end

  def write_csv(file, data, headers = nil)
    CSV.open(file, 'w') do |csv|
      csv << headers if headers
      data.each do |row|
        csv << (row.is_a?(CSV::Row) ? row.fields : row.values)
      end
    end
  end

  def filter_data(data)
    return data if @where_conditions.empty?
    data.select { |row| row[@where_conditions.keys.first] == @where_conditions.values.first }
  end

  def select_columns(data)
    return data if @select_columns == '*'
    return data if @select_columns.empty?
    data.map { |row| row.select { |key, _| @select_columns.include?(key) } }
  end

  def sort_data(data)
    return data unless @order_info
    data.sort_by! { |row| row[@order_info[:column]] }
    @order_info[:order] == :desc ? data.reverse : data
  end
end


def _main()
    #   # Select multiple columns with 'where' clause
    # request = MySqliteRequest.new
    # request = request.from('nba_player_data.csv')
    # request = request.select('*')
    # request = request.where('year_start', '1991')
    # request.run

    # # Select single column multiple 'where' clause
    # request = MySqliteRequest.new
    # request = request.from('nba_player_data.csv')
    # request = request.select('name')
    # request = request.where('name', 'Zaid Abdul-Aziz')
    # # request = request.where('year_start', '1991')
    # request.run
    
    # request = MySqliteRequest.new
    # request = request.insert('nba_player_data_copy.csv')
    # request = request.values({"name" => "Don Adamu","year_start" => "1971","year_end" => "1977","position" => "F","height" => "6-6","weight" => "210","birth_date" => "November 27, 1947","college" => "Northwestern University"})
    # request.run

    # # Select Multiple where
    # request = MySqliteRequest.new
    # request = request.from('nba_player_data.csv')
    # request = request.select('name')
    # request = request.where('college', 'University of California')
    # request = request.where('year_start', '1997')
    # request.run

    # request = MySqliteRequest.new
    # request = request.from('nba_player_data.csv')
    # request = request.select('name')
    # request = request.where('name', 'John Abramovic')
    # request.run
    
    #  The same as the above
    #  MySqliteRequest.new.from('nba_player_data.csv').select('name').where('name', 'John Abramovic').run

    # request = MySqliteRequest.new
    # request = request.delete()
    # request = request.from('nba_player_data_copy.csv')
    # request = request.where('name', 'Specify the name')
    # request.run

    # request = MySqliteRequest.new
    # request = request.delete()
    # request = request.from('nba_player_data_copy.csv')
    # request = request.where('name', 'Kareem Abdul-Jabbar')
    # request.run

end

_main()




