class Hash
  # Check to see if we contain all the specified keys
	def has_keys?(*keys)
		keys.each do |key|
			return false unless self.has_key? key
		end
		
		true
	end
end
