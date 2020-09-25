
require 'pry'
class Dog 

    
    attrs = {
        :id => "INTEGER PRIMARY KEY",
        :name => "TEXT",
        :breed => "TEXT",
    }

    attrs.keys.each do |key|
        attr_accessor key 
    end 
    
    def initialize(id: nil, name:, breed:)
        @name = name 
        @breed = breed 
        @id = id 
    end 
    def self.table_name 
        "#{self.to_s.downcase}s"
    end 
    def self.create_table 

        sql = <<-SQL 
        CREATE TABLE IF NOT EXISTS #{self.table_name} ( 
            id INTEGER PRIMARY KEY, 
            name TEXT, 
            breed TEXT
        )
        SQL
        DB[:conn].execute(sql)
    end 
    def self.drop_table 
        sql = <<-SQL 
        DROP TABLE #{self.table_name} 
        SQL
        DB[:conn].execute(sql)
    end 
    def self.new_from_db(array)
        id = array[0]
        name = array[1]
        breed = array[2]
        self.new(id:id, name:name, breed:breed)

    end 
    def save 
        sql = <<-SQL 
        INSERT INTO #{self.class.table_name} (name, breed)
        VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end 

    def self.create(name:, breed:)
        #binding.pry 
        dog = Dog.new(name: name, breed: breed)
        dog.save
        dog
    end 
    
    def self.find_by_name(name)
        sql = <<-SQL 
        SELECT *
        FROM #{self.table_name}
        WHERE name = ? 
        SQL
        
        DB[:conn].execute(sql, name).map do |row|
            self.create(row)
        end
    end 
    def self.find_by_id(id)
        sql = <<-SQL 
        SELECT * 
        FROM #{self.table_name}
        WHERE id = ?
        SQL
        result = DB[:conn].execute(sql, id)[0]
        Dog.new(id:result[0], name:result[1], breed:result[2])
    end 
    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE  name = ? AND breed = ?", name, breed)
        if !dog.empty?
            dog_data = dog[0]
            dog = Dog.new(dog_data[0], dog_data[1], dog_data[2])
        else
            dog = self.create(name: name, breed: breed)
        end
        dog
    end 
end 