require "csv"
require "rexml/document"
include REXML

doc = Document.new File.new("RATES.xml")

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

p conversion_hash

CSV.foreach("trans.csv") do |row|
  # use row here...
  p row
end

exit