class Dog

    attr_accessor :name, :breed
    attr_reader :id

    def initialize(id:nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end 

    def self.create_table
        sql = <<-SQL
            CREATE TABLE dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            )
        SQL

        DB[:conn].execute(sql)
    end 

    def self.drop_table 
        sql = <<-SQL
            DROP TABLE dogs 
        SQL

        DB[:conn].execute(sql)
    end 

    def self.new_from_db(row)
        
        id = row[0]
        name = row[1]
        breed = row[2]

        dog = Dog.new(id:id, name:name, breed:breed)
        dog
    end 

    def self.all 
        
        # Using SQL statement to get raw data from the table
        sql =<<-SQL
            SELECT *
            FROM dogs
        SQL
        # iterate all rows to create a new Ruby object for each row
        DB[:conn].execute(sql).map {|row| self.new_from_db(row)}
    end 

    def save
       
        if self.id
            self.update
        else 
        sql =<<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
        SQL
        
        # This won't work because it only associate object to db
        # DB[:conn].execute(sql, name, breed)
        DB[:conn].execute(sql, name, breed).map {|row| self.new_from_db(row)}
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        
        end 
        self
    end 

    def self.create(name:, breed:)
        dog = Dog.new(name:name, breed:breed)
        dog.save
        dog
    end 



    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = ?"
        dog = DB[:conn].execute(sql, id)[0]
        Dog.new(id:dog[0], name:dog[1], breed:dog[2])
    end 

    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
            if !dog.empty?
                new_dog = dog[0]
                dog = Dog.new(id:new_dog[0], name:new_dog[1], breed:new_dog[2])
            else 
                dog = self.create(name: name, breed: breed)
            end 
        dog 
    end 

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ?"
        dog = DB[:conn].execute(sql, name)[0]
        Dog.new(id:dog[0], name:dog[1], breed:dog[2])
    end 

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id =?"

        DB[:conn].execute(sql, name, breed, id)
    end 
    
    
end 