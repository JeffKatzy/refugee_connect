xml.instruct!
xml.Response do
    xml.Say("Hello.  Welcome #{@tutor.name}, please wait while we connect you with 
    #{@tutee.name}.  You're session should start in just a moment.  Please open your book to page
    #{@appointment.start_page}")
    xml.Dial do
    	xml.Number(+12154997415)
    end 
end

