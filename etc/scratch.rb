ROOT = './etc/content'
ARTIFACT = 'test'

throw 'Bad Directory' unless File.directory? ROOT

bundle = "#{ROOT}/#{ARTIFACT}"
throw 'no bundle' unless File.directory? bundle

lic_name = "#{bundle}/#{ARTIFACT}.lic"
art_name = "#{bundle}/#{ARTIFACT}.xml"
throw 'incorrect bundle format; no license' unless File.exist? lic_name
throw 'incorrext bundle format; no artifact' unless File.exist? art_name

lic = File.read lic_name
art = File.read art_name

puts lic
puts art
