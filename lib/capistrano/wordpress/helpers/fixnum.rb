class Fixnum
  # Get the ordinal string of the integer value
  def ordinal
    abs_number = self.to_i.abs
    
    if (11..13).include?(abs_number % 100)
      "th"
    else
      case abs_number % 10
        when 1; "st"
        when 2; "nd"
        when 3; "rd"
        else    "th"
      end
    end
  end
  
  # Get the ordinal string prefixed with the integer value
  def ordinalize
    "#{self}#{self.ordinal}"
  end
end
