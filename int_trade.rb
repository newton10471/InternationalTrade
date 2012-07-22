require "csv"
require "rexml/document"
include REXML

# return a hash of conversion rates
def get_conversion_info(ratesfile)

	doc = Document.new File.new(ratesfile)

	from_elements = []
	to_elements = []
	conversion_elements = []

	XPath.each( doc, "//from") { |element| from_elements << element.text } 
	XPath.each( doc, "//to") { |element| to_elements << element.text } 
	XPath.each( doc, "//conversion") { |element| conversion_elements << element.text } 

	conversion_hash = {}
	(0..(from_elements.size-1)).each do |count|
		conversion_hash[[from_elements[count], to_elements[count]]] = conversion_elements[count]
	end

	return conversion_hash
end

def find_items(item, itemfile)
	found_items = []
	CSV.foreach(itemfile) do |row|
  	if row[1] == item
  		found_items << row[2]
  	end
	end
	return found_items
end

desired_units = "USD"
p get_conversion_info("RATES.xml")
p find_items("DM1182", "trans.csv")
