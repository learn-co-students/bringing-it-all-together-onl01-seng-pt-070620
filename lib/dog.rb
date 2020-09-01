require 'pry'
class Dog
  attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE dogs (
    id INTEGER PRIMARY KEY,
    name TEXT,
    breed TEXT
    );
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE dogs
    SQL
    DB[:conn].execute(sql)
  end

  def save
    if id
      update
    else
    sql = <<-SQL
    INSERT INTO dogs (name,breed)
    VALUES (?,?)
    SQL
    DB[:conn].execute(sql,name,breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid()")[0][0]
      self
    end
  end

  def self.create(name: , breed:)
    Dog.new(name: name, breed: breed).tap do |dog|
      dog.save
    end
  end

  def self.new_from_db(row)
    Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE id IS ?
    SQL
    new_from_db(DB[:conn].execute(sql,id).first)
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE name IS ? AND breed IS ?
    SQL
    if DB[:conn].execute(sql, name,breed).empty?
      create(name: name, breed: breed)
    else
      new_from_db(DB[:conn].execute(sql, name,breed).first)
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE name is ?
    SQL
    new_from_db(DB[:conn].execute(sql,name).first)
  end

  def update
    sql = <<-SQL
    UPDATE dogs
    SET name = ?, breed = ?
    WHERE id IS ?
    SQL
    DB[:conn].execute(sql,self.name,self.breed,self.id)
  end
end