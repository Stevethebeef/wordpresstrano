# Extensions for the Fixnum class
class Fixnum
  # Get the ordinal string of this number
  #
  # Example:
  #   >> 1.ordinal
  #   => "st"
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
  
  # Get the ordinal string of this number and
  # prefix it with this number
  #
  # Example:
  #   >> 1.ordinalize
  #   => "1st"
  def ordinalize
    "#{self}#{self.ordinal}"
  end
end
