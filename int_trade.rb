# require 'bigdecimal'
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

		# @rates = []

		# (0..(from_elements.size-1)).each do |count|
		#   arrayelement = [from_elements[count], to_elements[count], conversion_elements[count]]
		# 	@rates << arrayelement
		# end

		# return @rates

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
		factor = 0 # default value
		from_pairs.each_with_index do |pair, index|
			p "pair: #{pair}, to_pairs: #{to_pairs}"
			p "pair[1]: #{pair[1]}, to_pairs[index][0]: #{to_pairs[index][0]}"
			if pair[1] == to_pairs[index][0]
				# factor << pair[2].to_f
				# factor << to_pairs[index][2].to_f
				factor = pair[2].to_f * to_pairs[index][2].to_f
			end
		end

		if factor == 0 
			puts "WARNING: no conversion value found!"
		end

		return factor
	end

	def build_conversion_table(desired_units)
		# find all the unique currencies
		keyarray = []
		@rates.keys.each do |keys| 
			keyarray << keys[0]
			keyarray << keys[1]
		end 

		desired_units_array = []
		desired_units_array << desired_units
		from_currencies = keyarray.uniq - desired_units_array

		# find conversion factors from each currency (EUR, AUD, CAD) to USD
		# find one that already exists to go to -> USD (which is CAD)
		# work backwards from that one?  going to the next which a) points to CAD, and b) isn't yet populated

		return from_currencies
	end

	def rates
		@rates
	end

end

# BigDecimal.mode(BigDecimal::ROUND_MODE, :banker)  # BigDecimal class method to set proper rounding behavior (Banker's rounding)
desired_units = "USD"
item = "DM1182"
myTrader = Trader.new
myTrader.get_rates("RATES.xml")
found_items = myTrader.find_items(item, "SAMPLE_TRANS.csv")

myTrader.rates.each do |rate|
	p rate
end
p myTrader.rates[["CAD","USD"]].to_f

p myTrader.build_conversion_table(desired_units)

p found_items

exit

total = 0

found_items.each do |item|
	str_amount, currency = item.split()
	amount = str_amount.to_f
	if (currency == desired_units)
		total += amount
		total = total.round(2)
	else
		factor = myTrader.conversion_factor(currency,desired_units)
		amount = amount * factor
		amount = amount.round(2)
		total += amount
	end
end

puts "total: #{total}"
# puts "The grand total of sales for item #{item} across all stores in #{desired_units} currency is #{total}."
# f = File.open("OUTPUT.txt", "w")
# f.puts(total)
# f.close