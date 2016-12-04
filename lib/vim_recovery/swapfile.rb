module VimRecovery
  class Swapfile < ::File

    Block0 = Struct.new :id, :version, :page_size, :mtime, :ino, :pid, :uname,
      :hname, :fname, :crypt_seed, :flags, :dirty

    # https://github.com/vim/vim/blob/95f096030ed1a8afea028f2ea295d6f6a70f466f/src/memline.c#L62
    VALID_BLOCK_IDS = %w{b0 bc bC bd}.freeze

    # https://github.com/vim/vim/blob/95f096030ed1a8afea028f2ea295d6f6a70f466f/src/memline.c#L143
    B0_MAGIC_LONG   = 0x30313233
    B0_MAGIC_INT    = 0x20212223
    B0_MAGIC_SHORT  = 0x10111213
    B0_MAGIC_CHAR   = 0x55
    B0_DIRTY        = 0x55
    B0_FF_MASK      = 3
    B0_SAME_DIR     = 4
    B0_HAS_FENC     = 8

    # https://github.com/vim/vim/blob/95f096030ed1a8afea028f2ea295d6f6a70f466f/src/option.h#L80
    EOL_UNIX        = 0 # NL
    EOL_DOS         = 1 # CR NL
    EOL_MAC         = 2 # CR

    EOL = {
      EOL_UNIX => :unix,
      EOL_DOS  => :dos,
      EOL_MAC  => :mac
    }.freeze

    # https://github.com/vim/vim/blob/95f096030ed1a8afea028f2ea295d6f6a70f466f/src/memline.c#L160
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

    def self.swapfile?(name)
      open(name) { |f| f.valid_block0? }
    end

    def encrypted?
      # "b0" not encrypted
      # "bc" encrypted (zip)
      # "bC" encrypted (blowfish)
      # "bd" encrypted (blowfish2)
      block0.id[1] != '0'
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
      Process.getpgid pid
      true
    rescue Errno::ESRCH
      false
    end

    # Flags

    # The original length of the filename field was 900 chars.  At some point
    # (flags were introduced in Vim 7.0) the last two bytes were used to store
    # "other things" ("dirty" char and flags).  When encrypted swapfiles were
    # introduced (Vim 7.3) another 8 bytes were used to store the crypt seed,
    # so the contemporary filename field size is 890.

    # Swap file is in directory of edited file (see ":help directory").
    def same_dir?
      B0_SAME_DIR & block0.flags > 0
    end

    def has_file_encoding?
      B0_HAS_FENC & block0.flags > 0
    end

    def file_format
      # "Zero means it's not set (compatible with Vim 6.x), otherwise it's
      # EOL_UNIX + 1, EOL_DOS + 1 or EOL_MAC + 1."
      EOL[(block0.flags & B0_FF_MASK) - 1]
    end

    def valid_block0?
      rewind
      VALID_BLOCK_IDS.include?(read 2)
    end

    private

    def block0
      @block0 ||=
        begin
          rewind
          Block0.new *read(1032).unpack(HEADER_FORMAT)
        end
    end

  end
end
