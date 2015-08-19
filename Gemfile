source 'https://rubygems.org'

gem 'berkshelf'

group :development do
   gem 'berkshelf', github: "berkshelf/berkshelf"
   gem 'foodcritic', '~> 3.0.3'
   gem 'stove', github: "sethvargo/stove"
end
#
group :plugins do
    gem "vagrant-berkshelf", github: "berkshelf/vagrant-berkshelf"
    gem "vagrant-omnibus", github: "schisamo/vagrant-omnibus"
end

group :integration do
  gem 'test-kitchen', '>=1.0.0.beta.3'
  gem 'kitchen-vagrant', :git => "git://github.com/opscode/kitchen-vagrant.git"
end
