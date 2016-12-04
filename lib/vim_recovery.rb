module VimRecovery

  # Strictly speaking, ".saa" will never be a swapfile because the loop
  # gives up at that name, but including it saves us a separate pattern.
  # https://github.com/vim/vim/blob/95f096030ed1a8afea028f2ea295d6f6a70f466f/src/memline.c#L4566
  SWAPFILES = ['*.sw[a-p]', '*.s[a-v][a-z]'].freeze
end

require 'vim_recovery/swapfile'
