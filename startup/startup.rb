# -------------------------------------------------
# 	Launch Java script to connect to jenkins 
# Author : orion1024
# Date : 2016
# -------------------------------------------------

require 'open-uri';
require 'tmpdir'


slave_name = ENV["COMPUTERNAME"]
jenkins_host = ENV["JENKINS_HOST"]
jenkins_user = ENV["JENKINS_USER"]
# jenkins_apitoken = ENV["JENKINS_APITOKEN"]
jenkins_apitoken = "a1329adde5a281e2afbbe0aedb9d93ac"

jarFullPathName = Dir.tmpdir() + "/slave.jar"

# To make sure the jar we have is the right version, we download it each time.
# if File.exist?(jarFullPathName)
	# FileUtils.rm 'NotExistFile', :force => true
# end

jarURL = "http://" + jenkins_host + ":8080/jnlpJars/slave.jar"

# puts "jar URL = " + jarURL

File.open(jarFullPathName, 'w') { |f|
	IO.copy_stream(open(jarURL), f)
}

jnlpURL = "http://" + jenkins_host + ":8080/computer/" + slave_name + "/slave-agent.jnlp"

#puts "JNLP URL = " + jnlpURL
javaCmd = "java -jar " + jarFullPathName + " -jnlpUrl " + jnlpURL + " -jnlpCredentials " + jenkins_user + ":" + jenkins_apitoken

puts "Command = " + javaCmd

system(javaCmd)