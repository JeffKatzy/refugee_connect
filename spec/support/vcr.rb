VCR.configure do |c|
	#configure
	c.cassette_library_dir = Rails.root.join("spec", "vcr")
	c.hook_into :fakeweb
end