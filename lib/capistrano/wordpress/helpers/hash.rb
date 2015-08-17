# Extensions for the Hash class
class Hash
  # Check to see if this hash contains all
  # the specified keys
  #
  # Example:
  #   >> { a: "alpha", b: "beta" }.has_keys? :a, :b
  #   => true
  #
  # Arguments:
  #   keys: (Splat)
	def has_keys?(*keys)
		keys.each do |key|
			return false unless self.has_key? key
		end
		
		true
	end
end
