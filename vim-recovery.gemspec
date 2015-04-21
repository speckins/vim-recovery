Gem::Specification.new do |spec|

  spec.name          = 'vim-recovery'
  spec.version       = '0.0.1'
  spec.authors       = ['Steven Peckins']
  spec.email         = ['steven.peckins@gmail.com']
  spec.summary       = 'A utility for finding and recovering Vim swapfiles'
  spec.description   = 'A description'
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  #spec.files         = ['lib/vim-recovery.rb']
  spec.executables   << 'vim-recovery'

end
