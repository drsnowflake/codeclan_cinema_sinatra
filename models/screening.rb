require_relative('../db/sql_runner')

class Screening
  attr_reader :id

  def initialize(options)
    @id = options['id'].to_i if options['id']
    @film_id = options['film_id'].to_i
    @show_time = options['show_time']
    @capacity = options['capacity'].to_i
  end

  def save
    values = [@film_id, @show_time, @capacity]
    sql = "INSERT INTO screenings
            (film_id, show_time, capacity)
            VALUES
            ($1, $2, $3)
            RETURNING id"
    @id = SqlRunner.run(sql, values).first['id'].to_i
  end

  def tickets
    values = [@id]
    sql = 'SELECT customers.* FROM customers
            INNER JOIN tickets ON tickets.customer_id = customers.id
            WHERE tickets.screening_id = $1'
    SqlRunner.run(sql, values).map { |customer| Customer.new(customer) }
  end

  def booked
    result = tickets
    result.count
  end

  def delete
    values = [@id]
    sql = 'DELETE FROM tickets
            WHERE screening_id = $1'
    SqlRunner.run(sql, values)
    sql = 'DELETE FROM screenings
            WHERE id = $1'
    SqlRunner.run(sql, values)
  end

  def self.most_popular
    sql = 'SELECT tickets.screening_id, COUNT (tickets.screening_id)
            FROM tickets
            GROUP BY screening_id
            ORDER BY count'
    screening = []
    screening << SqlRunner.run(sql).map { |screening| screening }.last['screening_id'].to_i
    sql = 'SELECT * FROM screenings
            INNER JOIN films ON films.id = screenings.film_id
            WHERE screenings.id = $1'
    p 'most popular film is '
    SqlRunner.run(sql, screening).each { |result| p "#{result['title']} - Showing at: #{result['show_time']}" }
  end

  def self.all
    sql = 'SELECT * FROM screenings
            INNER JOIN films ON films.id = screenings.film_id'
    SqlRunner.run(sql).each { |result| p "Film: #{result['title']} - Showing at: #{result['show_time']}" }
  end

  def self.delete_all
    sql = 'DELETE FROM screenings'
    SqlRunner.run(sql)
  end
end
