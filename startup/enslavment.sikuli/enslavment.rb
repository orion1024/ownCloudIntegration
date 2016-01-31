# ----------------------------------------------------------------------
# 	Executed at slave startup to connect them to Jenkins master
#	Author : orion1024
# 	Date : 2016
# ----------------------------------------------------------------------

require 'sikulix'
include Sikulix

############################

# Functions definitions

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
	
	if waitTime == 0
		waitTime = getAutoWaitTimeout()
	end
	
	while matchFound.nil? and duration < waitTime
		if not @waitRegion.nil?
			matchFound = waitRegion.exists(getScreenshotFile(waitScreenShotFile), 0.5)
		else
			matchFound = exists(getScreenshotFile(waitScreenShotFile), 0.5)
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

############################


connected = false

# Fetching JENKINS information from the environment variables
slave_name = ENV["SLAVE_NAME"]
jenkins_host = ENV["JENKINS_HOST"]
jenkins_user = ENV["JENKINS_USER"]
jenkins_password = ENV["JENKINS_PASSWORD"]


puts "Connecting to " + slave_name + "..."
myApp = App.focus("C:\\Program Files\\Mozilla Firefox\\firefox.exe http://" + jenkins_host + ":8080/login?from=/computer/" + slave_name)

puts "Waiting for firefox to load..."
smartWait("Jenkins_Logo.png", 30)

browserRegion = App.focusedWindow()

puts "Looking for login form..."
if browserRegion.nil?
	loginFormRegion = smartWait("Jenkins_LoginForm.png", 120)
else
	loginFormRegion = smartWait("Jenkins_LoginForm.png", 120, browserRegion)
end

if loginFormRegion.nil?
	puts "Couldn't find login form."
else

	puts "Now filling in login form..."
	
	if smartWaitAndClick("Jenkins_UserField.png", 2, loginFormRegion) != 1
		puts "Couldn't find the login field."
	else
	
		# to prevent any autofill from screwing up the paste
		sleep(2)
		
		paste(jenkins_user)
		type(Key.TAB)
		
		# to prevent any autofill from screwing up the paste
		sleep(1)
		
		paste(jenkins_password)
		
		if smartWaitAndClick("Jenkins_LogInButton.png", 2, loginFormRegion) != 1
			puts "Couldn't find the login button."
		else

			puts "Login form completed. Now looking for Jenkins Java Web Start button..."

			sleep(5)
			
			javaWebStartButtonFound = 0
			retries = 0
			while javaWebStartButtonFound != 1 and retries < 10
			
				# Sometimes the button is located at the very bottom of the page, getting there.
				type(Key.END)
				sleep(2)
				
				# Looking for the button.
				javaWebStartButtonFound = smartWaitAndClick("Jenkins_JavaWebLaunchButton.png", 5, browserRegion)
				
				# Not found ? let's try disconnecting the slave manually. Sometimes Kenkins thinks slave is still connected and so hides the button.
				if javaWebStartButtonFound != 1
					retries = retries + 1
					puts "Jenkins Java Web Start button not found. trying to bring it back, retry #%d" % retries
					
					# Disconnect button is on top of the page, so we go up.
					type(Key.HOME)
					sleep(2)
					
					# launching the disconnect action using the URL, it's better than using image recognition.
					smartWaitAndClick("Jenkins_DisconnectButton.png", 2, browserRegion)
					
					sleep(1)
					
					# jenkins asks for confirmation
					smartWaitAndClick("Jenkins_ConfirmDisconnectZone.png", 2, browserRegion, "Jenkins_ConfirmDisconnectButton.png", true)
					sleep(1)
				end		
			end
			
			if javaWebStartButtonFound == 1
			
				# We now wait for the connected image to appear.
				# But since Java is so annoying, we might have security prompts/warnings that we might need to clear before it consents to run the applet...
				# So we look for the connected image, but if it doesn't appear after a while we also check for such prompts.
				retries = 0
				while not connected and retries < 5
				
					connectedMatch = smartWait("Jenkins_Connected.png", 4)
					connected = not(connectedMatch.nil?)
					
					if not connected
						retries = retries + 1
						# No connected image ? there might be some prompt asking us something
						if smartWaitAndClick("Java_RunThisApplicationDialog.png", 1, browserRegion, "Java_RunThisApplicationRunButton.png", true) == 1
							puts "Found a Run this application dialog."
						end
						if smartWaitAndClick("Java_UpdateNeededDialog.png", 1, browserRegion, "Java_UpdateNeededDialog_LaterButton.png", true) == 1
							puts "Found a Java update dialog."
						end
					end
				end
				
				if not connected
					puts "Couldn't find jenkins connected image."
				end
			else
				puts "Couldn't find Jenkins Java Web Start button."
			end
		end
	end
end

if connected
	puts "Connected successfully to jenkins as slave " + slave_name + "."
else
	puts "Failed to connect to Jenkins."
end









