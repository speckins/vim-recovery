module VimRecovery
  class Command::List < Command
    def run
      each_swapfile do |swapfile|
        puts "[%s%s]\t%s\t%s" % [
          swapfile.modified?      ? 'M' : ' ',
          swapfile.still_running? ? 'R' : ' ',
          swapfile.path,
          swapfile.original_filename
        ]
      end
    end
  end
end
