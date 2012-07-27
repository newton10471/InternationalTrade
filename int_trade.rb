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

		@rates = {}
    (0..(from_elements.size-1)).each do |count|
    	@rates[ from_elements[count] + " " + to_elements[count] ] = conversion_elements[count]
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

	def calculate_extra_rates
		@rates["AUD USD"] = @rates["AUD CAD"].to_f * @rates["CAD USD"].to_f
		@rates["EUR USD"] = @rates["EUR AUD"].to_f * @rates["AUD USD"].to_f
	end

	def rates
		@rates
	end
end

desired_units = "USD"
item = "DM1182"
myTrader = Trader.new
myTrader.get_rates("RATES.xml")
myTrader.calculate_extra_rates
found_items = myTrader.find_items(item, "TRANS.csv")

total = 0

found_items.each do |item|
	str_amount, currency = item.split()
	amount = str_amount.to_f
	if (currency == desired_units)
		total += amount
		total = total.round(2)
	else
		factor = myTrader.rates[currency + " " + desired_units].to_f
		# p factor
		amount = amount * factor
		amount = amount.round(2)
		total += amount
	end
end

#puts "total: #{total}"
puts "The grand total of sales for item #{item} across all stores in #{desired_units} currency is #{total}."
f = File.open("OUTPUT.txt", "w")
f.puts(total)
f.close