#!/usr/bin/env ruby

# <xbar.title>External IP country flag emoji</xbar.title>
# <xbar.version>v1.5 beta 1</xbar.version>
# <xbar.author>Bruce Steedman</xbar.author>
# <xbar.author.github>MatzFan</xbar.author.github>
# <xbar.desc>Displays country flag emoji - e.g. for VPN use</xbar.desc>
# <xbar.dependencies>OS X 10.11</xbar.dependencies>

require 'open-uri'
require 'json'

begin

  cc = JSON.load(open('http://ifconfig.co/json'))
  country_code = cc['country_iso'].chomp.split ''
  c1, c2 = *country_code.map { |c| (c.ord + 0x65).chr.force_encoding 'UTF-8' }

  puts "\xF0\x9F\x87#{c1}\xF0\x9F\x87#{c2} " + cc['country'] + " • " + cc['asn_org']

  puts "---"

  if cc['city']
    puts "Ville : " + cc['city']
  end

  if cc['country']
    puts "Pays : " + cc['country']
  end

  if cc['time_zone']
    puts "Fuseau horaire : " + cc['time_zone']
  end

  puts "---"

  puts "IP : " + cc['ip']
  puts "Réseau : " + cc['asn_org'] + " (" + cc['asn'] + ")"

  if cc['hostname']
    puts "Hôte : " + cc['hostname']
  end

  if cc['country_eu']
    puts "---"

    puts "Union Européenne"
  end

rescue StandardError => err
  puts "🥸"
  puts "---"
  puts err.to_s
end
