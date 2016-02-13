# ----------------------------------------------------------------------
# 	Uses Sikuli to complete ownCloud first-time configuration wizard
#	Author : orion1024
# 	Date : 2016
# ----------------------------------------------------------------------


require 'sikulix'
include Sikulix

# Some methods that enhance sikuliX scripts
require_relative '../common/sikulix'

#######		Start of script		#########

puts fetchAndExecuteOwnCloudClient()
