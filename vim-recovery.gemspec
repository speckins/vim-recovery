require_relative 'lib/vim_recovery/version'

Gem::Specification.new do |spec|

  spec.name          = 'vim-recovery'
  spec.version       = VimRecovery::Version
  spec.authors       = ['Steven Peckins']
  spec.email         = ['steven.peckins@gmail.com']
  spec.summary       = 'A utility for finding and recovering Vim swapfiles'
  spec.homepage      = 'https://github.com/speckins/vim-recovery'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")

  spec.bindir        = 'exe'
  spec.executables   << 'vim-recovery'

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'

end
