# Look in the tasks/setup.rb file for the various options that can be
# configured in this Rakefile. The .rake files in the tasks directory
# are where the options are used.

begin
  require 'bones'
  Bones.setup
rescue LoadError
  begin
    load 'tasks/setup.rb'
  rescue LoadError
    raise RuntimeError, '### please install the "bones" gem ###'
  end
end

ensure_in_path 'lib'
require 'libfst'

task :default => 'spec:run'

PROJ.name = 'libfst'
PROJ.authors = 'Peter Magnusson'
PROJ.email = 'kmpm@birchroad.net'
#PROJ.url = 'no url yet'
PROJ.version = LibFST::VERSION
#PROJ.rubyforge.name = 'no name yet'
PROJ.summary = "Library for Festo Plc communication using CI and Easy-IP"
PROJ.description = <<END
Library for Festo Plc communication using CI and Easy-IP
END

PROJ.test.file = 'test/test.rb'

PROJ.spec.opts << '--color'

task :release => ["gem:release", "doc:release"]

# EOF
