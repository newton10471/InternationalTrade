require "csv"
require "rexml/document"
include REXML

class Trader
	# return a hash of conversion rates
	def get_rates(ratesfile)

		doc = Document.new File.new(ratesfile)

		from_elements = []
		to_elements = []
		conversion_elements = []

		XPath.each( doc, "//from") { |element| from_elements << element.text } 
		XPath.each( doc, "//to") { |element| to_elements << element.text } 
		XPath.each( doc, "//conversion") { |element| conversion_elements << element.text } 

		@rates = {}
		(0..(from_elements.size-1)).each do |count|
			@rates[[from_elements[count], to_elements[count]]] = conversion_elements[count]
		end

		return @rates
	end

	def find_items(item, itemfile)
		@found_items = []
		CSV.foreach(itemfile) do |row|
	  	if row[1] == item
	  		@found_items << row[2]
	  	end
		end
		return @found_items
	end

	def conversion_factor(from_unit, to_unit)
		# find all the pairs that start with from_unit
		from_pairs = {}
		@rates.each_with_index do |rate, index|
			if @rates.keys[index][0] == from_unit
				p rate
				p rate.class
				p @rates
				p @rates.class
				#from_pairs << rate
			end
			# p @rates.keys
			# if rate.keys[0] == from_unit
			# 	from_pairs << rate
			# end	
		end

		p "from_pairs: #{from_pairs}"

		# find all the pairs that end with to_unit


		# see if we can find a match

		result = 0 # change this
		return result
	end

end

desired_units = "USD"
myTrader = Trader.new
p myTrader.get_rates("RATES.xml")
found_items = myTrader.find_items("DM1182", "trans.csv")
p found_items

total = 0

found_items.each do |item|
	str_amount, currency = item.split()
	amount = str_amount.to_f
	p "amount: #{amount}, currency: #{currency}"
	if (currency == desired_units)
			total += amount
	else
		total += amount * myTrader.conversion_factor(currency,desired_units)
	end
end

p total
