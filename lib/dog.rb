class Dog

    attr_accessor :name, :breed, :id

    def initialize(id: nil , name: , breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs(
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            )
        SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE dogs")
    end

    def save
        if self.id
            self.update
        else
            sql = "INSERT INTO dogs (name, breed) VALUES (?,?)"
            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
       self 
    end

    def self.create(name:, breed:)
        dog_attr = {name: name, breed: breed}
        dog = Dog.new(dog_attr)
        dog.save
        dog
    end

    def self.new_from_db(row)
        dog_attr = {id: row[0], name: row[1], breed: row[2]}
        dog = Dog.new(dog_attr)
    end

    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = ?"
        result = DB[:conn].execute(sql,id)[0]
        dog = Dog.new(id: result[0], name: result[1], breed: result[2])
    end

    def self.find_or_create_by(name:,breed:)
        sql = <<-SQL 
            SELECT * 
            FROM dogs
            WHERE name = ? AND breed = ?
        SQL

        result = DB[:conn].execute(sql, name, breed)

        if !result.empty?
            dog = Dog.new(id: result[0][0], name: result[0][1], breed: result[0][2])
        else
            self.create(name: name, breed: breed)
        end
    end

    def self.find_by_name(name)
        result = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)[0]
        dog = Dog.new(id: result[0], name: result[1], breed: result[2])
    end

    def update
        sql = "UPDATE dogs SET name = ? , breed = ? WHERE id = ?"
        DB[:conn].execute(sql,self.name, self.breed, self.id)
    end

end