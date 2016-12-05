require 'vim_recovery'

module VimRecovery
  class Command
    def initialize(paths, options = {})
      @paths = paths
      @options = options
    end

    def patterns
      @patterns ||=
        if @options[:recursive]
          SWAPFILES.map { |swp| "**/#{swp}" }
        else
          SWAPFILES
        end
    end

    def each_swapfile &block
      @paths.each do |path|
        path = path.chomp '/'
        path_patterns = patterns.map { |swp| "#{path}/#{swp}" }

        Dir.glob(path_patterns, File::FNM_DOTMATCH).each do |filename|
          next unless File.file? filename

          begin
            swapfile = VimRecovery::Swapfile.open filename
            next unless swapfile.valid_block0?
            yield swapfile
          ensure
            swapfile.close
          end
        end
      end
    end
  end
end

require_relative 'command/list'
require_relative 'command/clean'
