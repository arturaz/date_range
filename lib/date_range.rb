module DateRange
  class << self
    DATE_REGEXP = %r{
      ^\s*
      (
        (\d{4})
        (-(\d{1,2})
          (-(\d{1,2})
            (\s+(\d{1,2})
              (:(\d{1,2})
                (:(\d{1,2}))?
              )?
            )?
          )?
        )?
      )
      \s*\-?\s*
      (
        (\d{4})
        (-(\d{1,2})
          (-(\d{1,2})
            (\s+(\d{1,2})
              (:(\d{1,2})
                (:(\d{1,2}))?
              )?
            )?
          )?
        )?
      )?
      \s*$
    }x

    # Parse out _str_ and return two Time objects.
    #
    # It will return nil if one of the times are corrupt (like 13th month)
    # or missing.
    #
    # It will also look at context if no end time is given so:
    # * <tt>2008</tt> becomes 2008-01-01 00:00:00 - 2008-12-31 23:59:59
    # * <tt>2008-01</tt> becomes 2008-01-01 00:00:00 - 2008-01-31 23:59:59
    # * <tt>2008-01-01</tt> becomes 2008-01-01 00:00:00 - 2008-01-01 23:59:59
    # * and so forth...
    def parse(str)
      match_data = str.match(DATE_REGEXP)
      # Oh my god, I hate this shit. Basically it prepares dates for 
      # Time.parse consuming because it's so stupid and ignorant it wants
      # to make me puke :(
      from = extract_time_string_from_match_data(match_data)
      to = extract_time_string_from_match_data(match_data, 12)

      begin
        from = Time.parse(from) unless from.nil?
      rescue ArgumentError
        from = nil
      end

      begin
        if to.nil? and not from.nil?
          case extract_context_from_match_data(match_data)
          when :year
            to = from.end_of_year
          when :month
            to = from.end_of_month
          when :day
            to = from.end_of_day
          when :hour
            to = from + (59 - from.min).minutes + (59 - from.sec)
          when :minute
            to = from + (59 - from.sec)
          end 
        else
          to = Time.parse(to)
        end
      rescue ArgumentError
        to = nil
      end

      [from, to]
    end

    # Check if _str_ is a date range.
    #
    # Date range format is ([] indicating optional parts):
    #
    # <code>yyyy[-MM[-dd[ hh[:mm[:ss]]]]][ - ][yyyy[-MM[-dd[ hh[:mm[:ss]]]]]]</code>
    def match?(str)
      str.match(DATE_REGEXP).nil? ? false : true
    end

    private
    # Extract context from match data. For example if user enters just
    # 2008 it will return :year.
    #
    # Return value meanings:
    #
    # * <tt>:year</tt>:      end range should be years end
    # * <tt>:month</tt>:     end range should be months end
    # * <tt>:nothing</tt>:   nothing should be done with end range
    def extract_context_from_match_data(m, offset=0)
      year, month, day, hour, minute, second = \
        extract_pieces_from_match_data(m, offset)

      if year and month and day and hour and minute and second
        :nothing
      elsif year and month and day and hour and minute
        :minute
      elsif year and month and day and hour
        :hour
      elsif year and month and day
        :day
      elsif year and month
        :month
      elsif year
        :year
      end
    end

    def extract_time_string_from_match_data(m, offset=0)
      pieces = extract_pieces_from_match_data(m, offset)

      # If nothing matched - there was no date.
      if pieces.compact.blank?
        nil
      else
        # month and day are required to start at 1
        pieces[1] ||= 1
        pieces[2] ||= 1
        # Convert everything to integer
        pieces.map!(&:to_i)

        "%04d-%02d-%02d %02d:%02d" % pieces
      end
    end
    
    def extract_pieces_from_match_data(m, offset=0)
      [
        m[2 + offset],  # year
        m[4 + offset],  # month
        m[6 + offset],  # day
        m[8 + offset],  # hour
        m[10 + offset], # minute
        m[12 + offset]  # seconds
      ]
    end
  end
end
