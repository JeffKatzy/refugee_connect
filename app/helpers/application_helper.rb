module ApplicationHelper
	
	def render_flash
	  rendered = []
	  flash.each do |type, messages|
	    messages.each do |m|
	      rendered << render(:partial => 'shared/flash', :locals => {:type => type, :message => m}) unless m.blank?
	    end
	  end
	  rendered.join('<br/>').html_safe
	end
end
