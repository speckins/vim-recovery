module VimRecovery
  class Swapfile < ::File


    Block0 = Struct.new :id, :version, :page_size, :mtime, :ino, :pid, :uname,
      :hname, :fname, :crypt_seed, :flags, :dirty

    B0_MAGIC_LONG   = 0x30313233
    B0_MAGIC_INT    = 0x20212223
    B0_MAGIC_SHORT  = 0x10111213
    B0_MAGIC_CHAR   = 0x55
    B0_DIRTY        = 0x55
    B0_FF_MASK      = 3
    B0_SAME_DIR     = 4
    B0_HAS_FENC     = 8

    EOL_UNIX        = 0 # NL
    EOL_DOS         = 1 # CR NL
    EOL_MAC         = 2 # CR

    EOL = {
      0 => :unix,
      1 => :dos,
      2 => :mac
    }

    HEADER_FORMAT = [
      'A2',   # identifier, "b0"
      'A10',  # version, e.g., "VIM 7.4"
      'V',    # page_size
      'V',    # mtime (not used)
      'V',    # inode
      'V',    # pid
      'A40',  # username or uid
      'A40',  # hostname
      'A890', # filename
      'a8',   # crypt seed (for encrypted swapfiles)
      'C',    # flags
      'C',    # dirty (0x00/0x55)
      #'l!',   # magic_long
      #'i!',   # magic_int
      #'s!',   # magic_short
      #'c',    # magic_char
    ].join ''

    # The original length of the filename field was 890 chars.  At some point
    # (flags were introduced in Vim 7.0) the last two bytes were used to store
    # "other things" ("dirty" char and flags).  When encrypted swapfiles were
    # introduced (Vim 7.3) another 8 bytes were used to store the crypt seed.

    def encrypted?
      # TODO
    end

    def modified?
      block0.dirty == B0_DIRTY
    end

    def mtime
      block0.mtime == 0 ? super : Time.at(block0.mtime)
    end

    def pid
      block0.pid
    end

    def original_filename
      block0.fname unless block0.fname.empty?
    end

    def still_running?
      Process.getpgid block0.pid
      true
    rescue Errno::ESRCH
      false
    end

    # Flags

    def same_dir?
      B0_SAME_DIR & block0.flags > 0
    end

    def has_file_encoding?
      B0_HAS_FENC & block0.flags > 0
    end

    def file_format
      EOL[block0.flags & B0_FF_MASK] #if has_file_encoding?
    end

    def valid_block0?
      rewind
      read(2) == 'b0'
    end

    private

    def block0
      rewind
      @block0 ||= Block0.new *read.unpack(HEADER_FORMAT)
    end

  end
end
