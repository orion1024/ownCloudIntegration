# ----------------------------------------------------------------------
# 	Contains methods used by SikuliX scripts
#	Author : orion1024
# 	Date : 2016
# ----------------------------------------------------------------------

require_relative 'generic'
require 'sikulix'
include Sikulix


#######		Functions definitions		#########

# Look for the proper screenshot files.
def getScreenshotFile(fileName)
	#TODO : should look for specialized screenshot file such as fileName_OS, fileName_COMPUTERNAME, and returns the most specific name found in the directory.
	#For now this is just a placeholder
	return fileName
end


# Simple wait() logic, but uses sleep() too to minimize the amount of CPU consumed by Sikuli scanning for the image
# waitScreenShot = fileName for the image to wait for
# waitTime = amount of time in seconds we look for the image before giving up
# waitRegion = Region object in which we will look for the image. If omitted, search is done on the whole screen.
# return value = return value of the exists() call, or empty if nothing was found
def smartWait(waitScreenShotFile, waitTime=0, waitRegion=0)
	## TODO
	duration = 0
	matchFound = nil
	realWaitScreenShotFile = getScreenshotFile(waitScreenShotFile)
	
	if waitTime == 0
		waitTime = getAutoWaitTimeout()
	end
	
	while matchFound.nil? and duration < waitTime
		if not @waitRegion.nil?
			matchFound = waitRegion.exists(realWaitScreenShotFile, 0.5)
		else
			matchFound = exists(realWaitScreenShotFile, 0.5)
		end
		
		if matchFound.nil?
			sleep(1)
			duration = duration + 1.5 # 1.5s because we slept for 1s and searched for 0.5s
		end
	end
	
	return matchFound
end

# Simple wait() and click() logic where click is called only if wait found something, but uses sleep() too to minimize the amount of CPU consumed by Sikuli scanning for the image
# waitScreenShot = fileName for the image to wait for
# clickScreenShot = file name for the image to click in. If omitted, the wait image is used.
# waitTime = amount of time in seconds we look for the image before giving up
# clickIsSubZoneofWait
# return value = return value of the click() call, or 0 if nothing was found
def smartWaitAndClick(waitScreenShot, waitTime=0, waitRegion=0, clickScreenShot="", searchClickInWaitResult=false)
	## TODO
	clickDone = 0
	
	if waitTime == 0
		waitTime = getAutoWaitTimeout()
	end
	
	matchFound = smartWait(waitScreenShot, waitTime, waitRegion)
	
	if not matchFound.nil?
	
		# where do we look for the click image ?
		# If no click image is specified, we use the wait result location to click directly. This way we don't even need to search it.
		if clickScreenShot == ""
			clickArgument = matchFound.getCenter()
			clickSearchRegion = Screen(0)
		else
			# We need to look for this image.
			clickArgument = getScreenshotFile(clickScreenShot)
			
			# Then if we were told to search for the click location in the wait image, we optimize the search by restricting it to the result we had from the smartWait() call.
			if searchClickInWaitResult
				clickSearchRegion = matchFound
			else
			# Otherwise, we need to search the entire screen (worst case)
				clickSearchRegion = Screen(0)
			end
		end
		
		duration = 0
		while clickDone == 0 and duration < 5 # for the click, since we waited for an image before, we shouldn't need to wait very long, so hard-coded default is short.
		
			clickDone = clickSearchRegion.click(clickArgument, 0.5)
			
			if clickDone == 0
				sleep(1)
				duration = duration + 1.5 # 1.5s because we slept for 1s and searched for 0.5s
			end
		end
		
	end
	
	return clickDone
	
end



# Launch owncloud client
# Return value : App object or nil if the client couldn't be launched.
def fetchAndExecuteOwnCloudClient(logEnabled=true, logfile="owncloud.log")
	
	owncloudBinary = fetchClientBinaries()
	
	if owncloudBinary == ""
		return nil
	else
		ownCloudCommand = owncloudBinary
		if logEnabled
			ownCloudCommand = ownCloudCommand + " --logfile " + logfile		
		end
		
		return App.focus(ownCloudCommand)
	end	
end
