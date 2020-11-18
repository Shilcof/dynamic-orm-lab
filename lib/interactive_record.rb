require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

    def self.inherited(base)
        base.column_names.each{|column|
            attr_accessor column.to_sym
        }
    end

    def self.table_name
        self.to_s.pluralize.downcase
    end

    def self.column_names
        DB[:conn].execute("pragma table_info('#{table_name}')").collect{|row| row["name"]}.compact
    end

    def initialize(hash = {})
        hash.each{|key, value|
            send("#{key}=", value)
        }
    end

    def table_name_for_insert
        self.class.table_name
    end

    def col_names_for_insert
        self.class.column_names[1..-1].join(", ")
    end

    def values_for_insert
        self.class.column_names[1..-1].collect{|column| "'#{send(column)}'"}.join(", ")
    end

    def save
        DB[:conn].execute("INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert});")
        @id = DB[:conn].execute("SELECT * FROM #{table_name_for_insert} WHERE last_insert_rowid()")[0][0]
    end

    def self.find_by_name(name)
        DB[:conn].execute("SELECT * FROM #{table_name} WHERE name = ?", name)
    end

    def self.find_by(attribute)
        DB[:conn].execute("SELECT * FROM #{table_name} WHERE #{attribute.keys[0].to_s} = ?", attribute.values[0])
    end

end


