module VimRecovery
  class Command::Clean < Command
    def run
      each_swapfile do |swapfile|
        next if swapfile.modified? || swapfile.still_running?

        puts swapfile.path if @options[:verbose]
        swapfile.close
        File.unlink swapfile
      end
    end
  end
end
