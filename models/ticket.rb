require_relative('../db/sql_runner')
require_relative('customer')

class Ticket
  attr_accessor :customer_id, :screening_id
  attr_reader :id

  def initialize(options)
    @id = options['id'].to_i if options['id']
    @customer_id = options['customer_id'].to_i
    @screening_id = options['screening_id'].to_i
  end

  def save
    # CALL check_capacity PRIOR TO TICKET SALE
    if check_capacity == false
      return p 'Screening at capacity unable to sell ticket'
    end

    # SELL TICKET IF SPACE IN SCREEN
    values = [@customer_id, @screening_id]
    sql = "INSERT INTO tickets
            (customer_id, screening_id)
            VALUES
            ($1, $2)
            RETURNING id"
    @id = SqlRunner.run(sql, values).first['id'].to_i

    Customer.bought_ticket(@customer_id)
  end

  def check_capacity
    values = [@screening_id]
    
    # GETTING TOTAL NUMBER OF TICKETS SOLD FOR PARTICULAR SCREENING
    sql = 'SELECT * FROM tickets
            WHERE screening_id = $1'
    tickets_sold = SqlRunner.run(sql, values).count

    # GETTING CAPACITY FOR SCREENING
    sql = 'Select screenings.capacity FROM screenings
            WHERE id = $1'
    capacity = SqlRunner.run(sql, values).first['capacity'].to_i

    # RETURNS TRUE IF THERE IS SPACE
    capacity - tickets_sold > 0
  end

  def delete
    values = [@id]
    sql = 'DELETE FROM tickets
            WHERE id = $1'
    SqlRunner.run(sql, values)
  end

  def update
    values = [@customer_id, @screening_id, @id]
    sql = 'UPDATE customers SET
            (customer_id, screening_id)
            =
            ($1, $2)
            WHERE id = $3'
    SqlRunner.run(sql, values)
  end

  def self.all
    sql = 'SELECT * FROM tickets'
    SqlRunner.run(sql).map { |ticket| Ticket.new(ticket) }
  end

  def self.delete_all
    sql = 'DELETE FROM tickets'
    SqlRunner.run(sql)
  end
end
