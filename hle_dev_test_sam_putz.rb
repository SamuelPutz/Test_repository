require "mysql2"

#generates cleaned names and sentences, and puts them in table

def hle_dev_test_sam(client)
  puts "Searching for names to clean..."
  selecting_new = "SELECT id, candidate_office_name FROM hle_dev_test_sam_putz WHERE clean_name is null AND sentence is null ORDER BY id;"
  new_names = client.query(selecting_new)
  if new_names.count == 0
  	puts "No new names."
  else
  	puts "Inserting new names and sentences..."
	  new_names.map do |name|
	  	id = "#{name["id"]}"
	  	clean_name = "#{name["candidate_office_name"].gsub(/^((?![\/,]).)*$/){|s| s.downcase}.gsub(/Dist\b/, "District").gsub(/ Rep\b/, " Representative").gsub(/, (.+)(?=\/)/, ' (\1)').gsub(/.+\//){|s| s.downcase }.gsub(/Twp.?\b/, "Township").gsub(/\btwp\b/, "township").gsub(/(.+\w)(Township)/, '\1 \2').gsub(/\bHwy\b/, "Highway").gsub(/\bhwy\b/, "highway").gsub(/(.+)\/(.+)\/(.+)/, '\3 \1 and \2').gsub(/, (.+)/, ' (\1)').gsub(/(.+)\/(.+)/, '\2 \1').gsub(/  /, ' ').gsub(/\b(\w+)\s\1\b/i, '\1').gsub(/\b(\w+\b\s\b\w+\b)\s\b\1/i, '\1').gsub(/(\w\w\w+)(\.)/, '\1').strip.gsub(/\//, "").gsub(/(\bschool) (district ?\d+) (.+)/, '\2 \1 \3').gsub(/Attorneys? Attorneys?/i, "attorney").gsub(/  /, ' ').split("(").map{|s| if s.chars.include?(")"); s.split(" ").map(&:capitalize).join(" "); else; s; end}.join("(").gsub(/(.+)(district) (\d+) \3/i, "\1\2 \3").gsub(/(\b\w+\b) (\b\w+\b) (\1)/i, '\2 \3').gsub(/(\b\w+\b) \1/i, '\1').gsub(/  /, ' ').gsub(/(District)(\d+)/, '\1 \2')}"
	  	sentence = "The candidate is running for the #{clean_name} office."
	  	update = "UPDATE hle_dev_test_sam_putz SET clean_name = \"#{clean_name}\", sentence = \"#{sentence}\" WHERE id = '#{id}';" 
	  	client.query(update) unless "#{name["candidate_office_name"]}" == "none given"
	  end
	delete = "DELETE FROM hle_dev_test_sam_putz WHERE clean_name is null or clean_name = '' or clean_name = 'unknown';"
	client.query(delete)
	puts "Task complete."
  end
end

client = Mysql2::Client.new(host: "db09.blockshopper.com", username: 'loki', password: 'v4WmZip2K67J6Iq7NXC')
client.query("use applicant_tests")
testing = hle_dev_test_sam(client)
client.close
puts testing
