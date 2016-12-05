# vim-recovery

vim-recovery is a utility to find and recover swapfiles.


### Rationale

After a system crash, my system is often littered with Vim swapfiles.  I
usually want to do two things.  (1) Recover my in-progress work (unsaved files)
and (2) remove any unmodified files to prevent Vim from prompting me about the
swapfile whenever I open a file.

`find . -type f -name "*.sw[a-p]"` doesn't take into account the actual type of
the file.  For example, it finds Shockwave Flash files (\*.swf).

vim-recovery searches directories for swap files and checks the header of the
file to determine if it actually is a Vim swapfile.


### Installation

    $ gem install vim-recovery


### Usage

    $ vim-recovery --help
    Usage:  vim-recovery [options] [paths...]
    Commands:
        -l, --list                       Find and list Vim swapfiles
            --clean                      Delete unmodified swapfiles if process is not still running
    Options:
        -r, --recursive                  Also search subdirectories
        -v, --verbose                    Be more verbose

            --version                    Show version
        -h, --help                       Display this help

**Finding swapfiles**

The "M" flag means the file was modified, and the "R" flag means the process is
still running.  The output is tab-delimited to make it easier to parse with
tools such as cut.

    $ vim-recovery --list
    [ R]	./.gitignore.swp	~speckins/git/vim-recovery/.gitignore
    [MR]	./.README.md.swp	~speckins/git/vim-recovery/README.md
    [ R]	./.vim-recovery.gemspec.swp	~speckins/git/vim-recovery/vim-recovery.gemspec
    [  ]	./.crashed.txt.swp	~speckins/git/vim-recovery/crashed.txt

**Removing unmodified swapfiles**

    $ vim-recovery --clean --verbose
    ./.crashed.txt.swp

    $ vim-recovery --list
    [ R]	./.gitignore.swp	~speckins/git/vim-recovery/.gitignore
    [MR]	./.README.md.swp	~speckins/git/vim-recovery/README.md
    [ R]	./.vim-recovery.gemspec.swp	~speckins/git/vim-recovery/vim-recovery.gemspec

**Recursively cleaning swapfiles**

    $ vim-recovery --clean --recursive --verbose
    ./.crashed.txt.swp
    ./lib/vim_recovery/.crashed.txt.swp

**Filtering the output of --list**

    $ vim-recovery --list --recursive
    [ R]	./.gitignore.swp	~speckins/git/vim-recovery/.gitignore
    [MR]	./.README.md.swp	~speckins/git/vim-recovery/README.md
    [ R]	./.vim-recovery.gemspec.swp	~speckins/git/vim-recovery/vim-recovery.gemspec
    [M ]	./.crashed.txt.swp	~speckins/git/vim-recovery/crashed.txt

    $ vim-recovery --list --recursive | grep -a '^\[M \]' | cut -f2
    ./.crashed.txt.swp


### Vim options

The directory option can be added to .vimrc to make it easier to find
swapfiles.  This is not necessary to use vim-recovery, but it can make it
faster.  (It takes a long time to search the 900,000+ files in my home
directory.)

    " .vimrc:
    set directory=~/tmp/swapfiles//

> For Unix and Win32, if a directory ends in two path separators "//"
> or "\\\\", the swap file name will be built from the complete path to
> the file with all path separators substituted to percent '%' signs.
> This will ensure file name uniqueness in the preserve directory.
