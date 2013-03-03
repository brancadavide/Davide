#!/usr/bin/env ruby

# Creates a Forward,- and ReverseLookup- File for Bind9
# Requires parameter 1 the domainname
#          parameter 2 the CIDRE
#          'socket' from the library

require 'socket'
require 'optparse'


# get current date (YearMonthDay) as integer, used as Serial for the Zone-files
def datum
t = Time.now
date = t.strftime("%y%m%d")
end

# gets the host-ip
def get_own_ip
l = UDPSocket.open
l.connect '66.249.95.255',1
l.addr.last
end

# creates the ForwardLookup-file using parameter soa
#requires altough date and host-ip , probably worth think about changing implementation of those..
def forward_zone(s)
textTest = File.open( s+".zone",'w')
		textTest.puts ";
; BIND data file for " + s+ " zone
;
$TTL	604800
@	IN	S	"+s+"  webmaster@"+s+". (
			 "+datum+"1		; Serial
			 604800		; Refresh
			  86400		; Retry
			2419200		; Expire
			 604800 )	; Negative Cache TTL
;
@	IN	NS	ns1."+s+"
@	IN	A	"+get_own_ip+"
" 

textTest.close
end


# gets the right arpa. - entry by using the cidre

def get_arpa(c,ip)
arpa = ip
	if c >= 8 && c < 16
		arpa = ip.split(".")
		arpa = arpa.last(3).reverse
		arpa = arpa.join(".").to_s
	elsif c >= 16 && c < 24
		arpa = ip.split(".").last(2).reverse
		arpa= arpa.join(".").to_s
	else c >= 24
		arpa = arpa.split(".").last
		return arpa
		
	end
		  
end

#creates the ReverseLookup=file using arpa and soa
#requires altough date and host-ip , probably worth think about changing implementation of those..
def reverse_zone(s,a)
textTest = File.open(a+".arpa",'w')
textTest.puts "; 
;BIND data file for " + s+ " reverse lookup
$TTL	604800
@	IN	SOA	"+s+"  webmaster@"+s+". (
			 "+datum+"		; Serial
			 604800		; Refresh
			  86400		; Retry
			2419200		; Expire
			 604800 )	; Negative Cache TTL
;
@	IN	NS	ns1."+s+"
"+a+"	IN	PTR	 ns1."+s+"."


textTest.close
end

begin
	optparse.parse!
	mandatory = [:domain, :cidre]
	missing = mandatory.select{ |param| options[param].nil?}
	if not missing.empty?
		puts "Missing options: #{missing.join(', ')}"
		puts optparse
		exit
	end

rescue OptionParser::InvalidOption, OptionParser::MissingArgument
	puts $!.to_s
	puts optparse
	exit
end


puts "Generate Bind-Files: #{options.inspect}"


