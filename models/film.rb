require_relative('../db/sql_runner')

require_relative('customer')

class Film
  attr_accessor :title, :price
  attr_reader :id

  def initialize(options)
    @id = options['id'].to_i if options['id']
    @title = options['title']
    @price = options['price'].to_i
  end

  def save
    values = [@title, @price]
    sql = "INSERT INTO films
            (title, price)
            VALUES
            ($1, $2)
            RETURNING id"
    @id = SqlRunner.run(sql, values).first['id'].to_i
  end

  def delete
    # deleting tickets

    values = [@id]
    sql = 'SELECT tickets.id FROM tickets
            INNER JOIN screenings ON screenings.id = tickets.screening_id
            INNER JOIN films ON films.id = screenings.film_id
            WHERE films.id = $1'
    results = SqlRunner.run(sql, values).map { |screening| screening['id'] }
    results.each do |result|
      value = []
      value = value << result.to_i
      sql = 'DELETE FROM tickets
              WHERE id = $1'
      SqlRunner.run(sql, value)
    end

    # deleting screenings

    sql = 'DELETE FROM screenings
            WHERE film_id = $1'
    SqlRunner.run(sql, values)

    # deleting films

    sql = 'DELETE FROM films
            WHERE id = $1'
    SqlRunner.run(sql, values)
  end

  def update
    values = [@name, @funds, @id]
    sql = 'UPDATE films SET
            (title, price)
            =
            ($1, $2)
            WHERE id = $3'
    SqlRunner.run(sql, values)
  end

  def self.all
    sql = 'SELECT * FROM films'
    SqlRunner.run(sql).map { |film| Film.new(film) }
  end

  def self.find_one(id_to_find)
    values = []
    values << id_to_find
    sql = 'SELECT * FROM films
            WHERE id = $1'
    SqlRunner.run(sql,values).map { |film| Film.new(film) }
  end

  def self.delete_all
    sql = 'DELETE FROM films'
    SqlRunner.run(sql)
  end
end
