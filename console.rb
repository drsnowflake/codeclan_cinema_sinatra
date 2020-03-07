require('pry-byebug')

require_relative('models/film')
require_relative('models/ticket')
require_relative('models/customer')
require_relative('models/screening')

Ticket.delete_all
Screening.delete_all
Film.delete_all
Customer.delete_all

customer1 = Customer.new(
  'name' => 'Rob M',
  'funds' => 10_000
)

customer2 = Customer.new(
  'name' => 'Fred B',
  'funds' => 5000
)

customer1.save
customer2.save

film1 = Film.new(
  'title' => 'Onward',
  'price' => 500
)

film2 = Film.new(
  'title' => 'Sonic The Hedgehog',
  'price' => 500
)

film1.save
film2.save

screening1 = Screening.new(
  'film_id' => film1.id,
  'show_time' => '10:00',
  'capacity' => 5
)

screening2 = Screening.new(
  'film_id' => film1.id,
  'show_time' => '12:00',
  'capacity' => 5
)

screening3 = Screening.new(
  'film_id' => film2.id,
  'show_time' => '14:00',
  'capacity' => 5
)

screening1.save
screening2.save
screening3.save

ticket1 = Ticket.new(
  'customer_id' => customer1.id,
  'screening_id' => screening1.id
)

ticket2 = Ticket.new(
  'customer_id' => customer2.id,
  'screening_id' => screening1.id
)

ticket3 = Ticket.new(
  'customer_id' => customer1.id,
  'screening_id' => screening2.id
)

ticket4 = Ticket.new(
  'customer_id' => customer2.id,
  'screening_id' => screening3.id
)

ticket1.save
ticket1.save
ticket1.save
ticket2.save
ticket2.save
ticket2.save
ticket1.save
ticket3.save
ticket3.save
ticket3.save
ticket4.save
ticket4.save

binding.pry
nil
