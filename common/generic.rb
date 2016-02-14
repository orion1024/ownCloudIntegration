# ----------------------------------------------------------------------
# 	Contains generic methods used by other scripts
#	Author : orion1024
# 	Date : 2016
# ----------------------------------------------------------------------

require 'fileutils'

# Get the appropriate latest built binaries from the build clients
# return value = the path to the fetched executable, if the executables were successfully fetched, or empty string otherwise 
def fetchClientBinaries()

	# This environment variable should be set by Jenkins to point to the appropriate share, that contains the latest built client.
	binRemoteLocation = ENV["BIN_REMOTE_LOCATION"]
	
	# This environment variable should be set by Jenkins to point to the appropriate share, that contains the latest built client.
	binLocalLocation = ENV["BIN_LOCAL_LOCATION"]
	
	# Abort if environment variables are not set.
	if binRemoteLocation.nil? or binLocalLocation.nil?
		return ""
	else
	
		if File.exist?(binLocalLocation)
			# First clean the local directory
			FileUtils.rm_r Dir.glob(binLocalLocation + '/*')
		else
			# or create the directory if it does not exist
			FileUtils.mkpath(binLocalLocation)
		end
		
		# then we copy from the remote share
		FileUtils.cp_r  binRemoteLocation + '/.', binLocalLocation
		
		# And finally check if the executable is there. Its name varies depending on the OS
		case RbConfig::CONFIG["host_os"]
		when "mswin32", "mswin64"
			binFile = "owncloud.exe"
		else
			binFile = "owncloud"
		end
		
		binFileFullPath = binLocalLocation + '/' + binFile
		
		if File.exist?(binFileFullPath)
			return binFileFullPath
		else
			puts binFileFullPath + " not found, fetch failed."
			return ""
		end
	end
	
end



