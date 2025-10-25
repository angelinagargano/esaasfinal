# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# movies = [{:title => 'Aladdin', :rating => 'G', :release_date => '25-Nov-1992'},
#     	  {:title => 'The Terminator', :rating => 'R', :release_date => '26-Oct-1984'},
#     	  {:title => 'When Harry Met Sally', :rating => 'R', :release_date => '21-Jul-1989'},
#       	  {:title => 'The Help', :rating => 'PG-13', :release_date => '10-Aug-2011'},
#       	  {:title => 'Chocolat', :rating => 'PG-13', :release_date => '5-Jan-2001'},
#       	  {:title => 'Amelie', :rating => 'R', :release_date => '25-Apr-2001'},
#       	  {:title => '2001: A Space Odyssey', :rating => 'G', :release_date => '6-Apr-1968'},
#       	  {:title => 'The Incredibles', :rating => 'PG', :release_date => '5-Nov-2004'},
#       	  {:title => 'Raiders of the Lost Ark', :rating => 'PG', :release_date => '12-Jun-1981'},
#       	  {:title => 'Chicken Run', :rating => 'G', :release_date => '21-Jun-2000'},
#   	 ]

# movies.each do |movie|
#   Movie.create!(movie)
# end

require 'csv'

    # Specify the path to your CSV file
    csv_file_path = Rails.root.join('db', 'seeds', 'dance_events.csv')

    # Ensure the file exists before attempting to read it
    if File.exist?(csv_file_path)
      CSV.foreach(csv_file_path, headers: true) do |row|
        # Assuming your model is named 'MyModel'
        # Map CSV headers to model attributes
        Event.find_or_create_by!(
          id: row['ID'],
          name: row['Name'],
		  venue: row['Venue'],
		  date: row['Date'],
		  time: row['Time'],
		  style: row['Style'],
		  location: row['Location'],
		  price: row['Price'],
		  description: row['Description'],
		  tickets: row['Tickets']
          # Add more mappings as needed
        )
      end
      puts "Successfully imported data from #{csv_file_path}"
    else
      puts "CSV file not found at #{csv_file_path}"
    end
