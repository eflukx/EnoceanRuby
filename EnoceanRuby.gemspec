Gem::Specification.new do |s|
  s.name        = 'EnoceanRuby'
  s.version     = '0.2.0'
  s.licenses    = ['MIT']
  s.summary     = "Enocean ESP/EEP implementation"
  s.description = "This gem enables communication to an Enocean gateway device using the (serial) ESP protocol."
  s.authors     = ["Lars-Jørgen Kristiansen", "Rogier Lodewijks", "Christian a.k.a. mccare"]
  s.email       = 'whiterabbit@rabbithole.to'
  s.files       = [ 'lib/enocean.rb',
                    'lib/enocean/overrides_types_tools.rb',
                    'lib/enocean/checksum.rb',
                    'lib/enocean/reader.rb',
                    'lib/enocean/writer.rb',
                    'lib/enocean/esp3/base_packet.rb',
                    'lib/enocean/esp3/radio.rb',
                    'lib/enocean/esp3/rorg.rb',
                    'lib/enocean/esp3/common_command.rb',
                    'lib/enocean/esp3/commands.rb',
                    'lib/enocean/esp3/response.rb',
                    'lib/enocean/esp3/responses.rb',
                    'lib/enocean/esp3/event.rb',
                    'lib/enocean/esp3/events.rb',
                    'lib/enocean/esp3/esp_pretty_print.rb',
                    'lib/enocean/eep/eep.rb']
  s.homepage    = 'https://github.com/eflukx/EnoceanRuby'
  # s.add_runtime_dependency 'forwardable'
end