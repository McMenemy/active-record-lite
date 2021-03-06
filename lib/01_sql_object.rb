require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  attr_accessor :columns, :table_name, :attributes

  def initialize(params = {})
    params.each do |column, value|
      raise "unknown attribute '#{column}'" unless self.class.columns.include?(column.to_sym)
      send("#{column}=", value)
    end
  end

  def self.columns
    if @columns.nil?
      column_str_array = DBConnection.execute2(<<-SQL)
        SELECT
          *
        FROM
          "#{self.table_name}"
      SQL

      @columns = []

      column_str_array[0].each do |column|
        @columns << column.to_sym
      end
    end

    @columns
  end

  def self.finalize!
    self.columns

    @columns.each do |column|

      define_method("#{column}=") do |value|
        self.attributes[column] = value
      end

      define_method("#{column}") do
        self.attributes[column]
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    default_table_name = "#{self.name.downcase}s"
    @table_name ||= default_table_name
  end

  def self.all
    all_hashes = DBConnection.execute(<<-SQL)
      SELECT
        "#{self.table_name}".*
      FROM
        "#{self.table_name}"
    SQL

    self.parse_all(all_hashes)
  end

  def self.parse_all(results)
    object_array = []

    results.each do |hash|
      sym_hash = {}

      hash.each do |column, value|
        sym_hash[column.to_sym] = value
      end

      object_array << self.new(sym_hash)
    end

    object_array
  end

  def self.find(id)
    datum = DBConnection.execute(<<-SQL)
      SELECT
        "#{self.table_name}".*
      FROM
        "#{self.table_name}"
      WHERE
        "#{self.table_name}".id = "#{id}"
    SQL

    return nil if datum.empty?

    self.parse_all(datum)[0]
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    @attributes.values
  end

  def insert
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end
end

class Cat < SQLObject
end
