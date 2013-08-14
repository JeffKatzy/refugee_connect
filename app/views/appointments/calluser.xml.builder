xml.instruct!
xml.Response do
    xml.Say(" Hello.  Welcome #{@tutor.name}, please wait while we connect you with 
    #{@tutee.name}.  You're session should start in just a moment.  Please open your book to page.")
    xml.Dial do
    	xml.Number((@tutee.cell_number).to_i)
    end 
end

