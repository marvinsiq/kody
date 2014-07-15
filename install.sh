bundle install
gem build kody.gemspec
gem install ./kody-*.gem
notify-send 'FINISH!' 'The Gem was installed.' --icon=dialog-information
