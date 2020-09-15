class Dog 
    attr_accessor :id, :name, :breed 
    def initialize(id:nil, name:, breed:)
        @id = id
        @name = name 
        @breed = breed
    end 

    def self.create_table 
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
            id INTERGER PRIMARY KEY,
            name TEXT,
            breed text
        )
        SQL
        DB[:conn].execute(sql)
    end 

    def self.drop_table
        sql = "DROP TABLE dogs"
        DB[:conn].execute(sql)
    end 

    def save
        sql = <<-SQL 
        INSERT INTO dogs (name, breed) 
        VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end 

    def self.create(name:, breed:)
        dog = self.new(name: name, breed: breed)
        dog.save
        dog
    end 

    def self.new_from_db(row) 
        name = row[1]
        breed = row[2]
        id = row[0]
        self.new(id: id, name: name, breed: breed,)
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE id = ?
        SQL
        DB[:conn].execute(sql,id).map do |row|
            self.new_from_db(row)
        end.first
    end 

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
          SELECT * 
          FROM dogs
          WHERE name = ? 
          AND breed = ?
        SQL
    
    
        dog = DB[:conn].execute(sql, name, breed).first
    
        if dog
            new_dog = self.new_from_db(dog)
        else
            new_dog = self.create({:name => name, :breed => breed})
        end
        new_dog
    end

    def self.find_by_name(name)
        sql = <<-SQL
          SELECT * FROM dogs WHERE name = ?
        SQL
    
        DB[:conn].execute(sql, name).map do |row|
          self.new_from_db(row)
        end.first
    end

    def update
        sql = <<-SQL
          UPDATE dogs SET name = ?, breed = ? WHERE id = ?
          SQL
    
          DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end 