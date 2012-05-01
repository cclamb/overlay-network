module Util

  def Util::find_file name
    if File.exists? name
      File.open(name) do |file|
        Marshal.load file
      end
    else
      nil
    end
  end

  def Util::process_options
    options = {}
    option_parser = OptionParser.new do |opts|

      # Create a switch
      opts.on('-s', 
        '--start',
        'Start the overlay simulation') do
        options[:start] = true
      end

      opts.on('-t', 
        '--terminate',
        'Stop the overlay simulation') do
        options[:stop] = true
      end

    end
    option_parser.parse!
    return options
  end

end