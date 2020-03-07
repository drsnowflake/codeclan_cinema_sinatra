require_relative('../db/sql_runner')
require_relative('film')

class Customer

  attr_accessor :name, :funds
  attr_reader :id

  def initialize(options)
    @id = options['id'].to_i if options['id']
    @name = options['name']
    @funds = options['funds'].to_i
  end

  def save
    values = [@name, @funds]
    sql = "INSERT INTO customers
            (name, funds)
            VALUES
            ($1, $2)
            RETURNING id"
    @id = SqlRunner.run(sql, values).first['id'].to_i
  end

  def funds
    sql = 'SELECT customers.funds FROM customers'
    return SqlRunner.run(sql).first['funds'].to_i
  end

  def delete
    values = [@id]
    sql = 'DELETE FROM tickets
            WHERE customer_id = $1'
    SqlRunner.run(sql,values)
    sql = 'DELETE FROM customers
            WHERE id = $1'
    SqlRunner.run(sql, values)
  end

  def update
    values = [@name, @funds, @id]
    sql = 'UPDATE customers SET
            (name, funds)
            =
            ($1, $2)
            WHERE id = $3'
    SqlRunner.run(sql, values)
  end

  def tickets
    values = [@id]
    sql = 'SELECT tickets.* FROM tickets
            INNER JOIN screenings ON tickets.screening_id = screenings.id
            WHERE tickets.customer_id = $1'
    SqlRunner.run(sql, values).map{|film|Film.new(film)}
  end

  def booked
    result = tickets()
    result.count
  end

  def self.bought_ticket(customer_id)
    values = [customer_id]
    sql = 'SELECT * FROM customers
            INNER JOIN tickets ON customers.id = tickets.customer_id
            INNER JOIN screenings ON screenings.id = tickets.screening_id
            INNER JOIN films ON films.id = screenings.film_id
            WHERE customers.id = $1'
    data = SqlRunner.run(sql, values).first
    new_funds = data['funds'].to_i - data['price'].to_i
    name = data['name']
    Customer.update(name, new_funds, customer_id)
  end

  def self.update(name, funds, id)
    values = [name, funds, id]
    sql = 'UPDATE customers SET
            (name, funds)
            =
            ($1, $2)
            WHERE id = $3'
    SqlRunner.run(sql, values)
  end

  def self.all
    sql = 'SELECT * FROM customers'
    SqlRunner.run(sql).map{ |customer| Customer.new(customer) }
  end

  def self.delete_all
    sql = "DELETE FROM customers"
    SqlRunner.run(sql)
  end

end
