slave_name = ENV["SLAVE_NAME"]
puts "Connecting to " + slave_name + "..."
myApp = App.focus("C:\\Program Files\\Mozilla Firefox\\firefox.exe http://192.168.255.253:8080/login?from=/computer/" + slave_name)

sleep(30)

wait("JenkinsLogo.png",5)

wait("JenkinsLoginForm.png")
click("JenkinsUserField.png")
paste("slave")
type(Key.TAB)

click("JenkinsPasswordField.png")
paste("v3VFZnkkj0h1vCqx4Pz2")
click("JenkinsLogInButton.png")

sleep(2)
type(Key.END)

begin
    wait("JenkinsJavaWebLaunchButton.png",5)
    click("JenkinsJavaWebLaunchButton.png")
rescue
    wait("JenkinsBringBackOnline.png")
    click("JenkinsBringBackOnline.png")
    retry

end

begin
    wait("JavaRunThisApplicationDialog.png",5)
    click("JavaRunThisApplicationRunButton.png")
rescue
end

begin
    wait("JenkinsConnected.png",15) 
    connected = true
rescue
    connected = false
end

puts connected









