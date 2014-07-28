# => seed sample data by running
# => bundle exec rake db:seed

alice = User.create!({
  name: 'Alice', email: 'alice@example.com', grade: 'Admiral', organisation: 'Applebees', staff_number: 'AAAA1111'
})

bob = User.create!({
  name: 'Bob', email: 'bob@example.com', grade: 'Brigadier', organisation: 'Burger King', staff_number: 'BBBB2222'
})

carol = User.create!({
  name: 'Carol', email: 'carol@example.com', grade: 'Captain', organisation: 'Chuck E Cheese', staff_number: 'CCCC3333'
})

dave = User.create!({
  name: 'Dave', email: 'dave@example.com', grade: 'Dishwasher', organisation: 'Dairy Queen', staff_number: 'DDDD4444'
})

eve = User.create!({
  name: 'Eve', email: 'Eve@example.com', grade: 'Ensign', organisation: 'El Pollo Bronco', staff_number: 'EEEE5555'
})

Agreement.create!(staff_member: bob, manager: alice)
Agreement.create!(staff_member: carol, manager: alice)
Agreement.create!(staff_member: dave, manager: alice)
Agreement.create!(staff_member: eve, manager: bob)
