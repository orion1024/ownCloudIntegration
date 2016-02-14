# ----------------------------------------------------------
# 	Executes a set of scripts based on given arguments
#		and the content of the script folders.
# Author : orion1024
# Date : 2016
# ----------------------------------------------------------

require 'open3'

# Set current directory to script directory
Dir.chdir(File.dirname(__FILE__))

if ARGV[0].nil?
	puts "No argument found. Syntax : " + File.basename(__FILE__) + " test_to_run"
	return 1
else
	testToRun = ARGV[0]
	# if $1 = mytest we try to load $1/$1.rb
	# note : goal is to enhance this later to launch several scripts in the specified folder.
	testPath = testToRun + '/' + testToRun + '.rb'
	puts "Executing " + testPath + "..."
	system("jruby " + testPath)
	puts "Exit code = " + $?.exitstatus.to_s
end

