require 'bigdecimal'
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

		@rates = []

		(0..(from_elements.size-1)).each do |count|
		  arrayelement = [from_elements[count], to_elements[count], conversion_elements[count]]
			@rates << arrayelement
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

	def conversion_factors(from_unit, to_unit)
		# find all the pairs that start with from_unit
		from_pairs = []
		@rates.each_with_index do |rate, index|
			if @rates[index][0] == from_unit
				from_pairs << rate
			end	
		end

		#p "from_pairs: #{from_pairs}"

		# find all the pairs that end with to_unit
		to_pairs = []
		@rates.each_with_index do |rate, index|
			if @rates[index][1] == to_unit
				to_pairs << rate
			end	
		end

		#p "to_pairs: #{to_pairs}"


		# see if we can find a match
		factors = [] # default value
		from_pairs.each_with_index do |pair, index|
			if pair[1] == to_pairs[index][0]
				factors << pair[2].to_f
				factors << to_pairs[index][2].to_f
			end
		end

		return factors
	end

end

BigDecimal.mode(BigDecimal::ROUND_MODE, :banker)  # BigDecimal class method to set proper rounding behavior (Banker's rounding)
desired_units = "USD"
item = "DM1182"
myTrader = Trader.new
myTrader.get_rates("RATES.xml")
found_items = myTrader.find_items(item, "trans.csv")

total = 0

found_items.each do |item|
	str_amount, currency = item.split()
	amount = str_amount.to_f
	if (currency == desired_units)
			total += amount
			# p "total is #{total}"
			# (round total)
			total = total.round(2)
	else
		factors = myTrader.conversion_factors(currency,desired_units)
		factors.each do |factor|
			amount = amount * factor
			# p "amount is #{amount}"
			# (round amount)
			amount = amount.round(2)
		end
		total += amount
	end
end

# puts "The grand total of sales for item #{item} across all stores in #{desired_units} currency is #{total}."
f = File.open("OUTPUT.txt", "w")
f.puts(total)
f.close