require 'pry'
class Dog

  attr_accessor :id,:name, :breed

  def initialize(id: nil,name:,breed:)
    @name = name
    @breed = breed
  end

  def self.create_table
    self.drop_table
    self.create_table
  end

  def self.drop_table
    sql=<<-SQL
      DROP TABLE IF EXISTS dogs
    SQL
    DB[:conn].execute(sql)
  end

  def self.create_table
    sql=<<-SQL
    CREATE TABLE dogs(
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

end
