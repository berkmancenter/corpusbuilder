guard :rspec, cmd: 'bundle exec rspec' do
  watch('spec/spec_helper.rb')                        { "spec" }
  watch('config/routes.rb')                           { "spec/routing" }
  watch('app/controllers/application_controller.rb')  { "spec/controllers" }
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^app/(.+)\.rb$})                           { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^app/api/(.+)/(.+)\.rb$})                  { |m| "spec/api/#{m[1]}/#{m[2]}_spec.rb" }
  watch(%r{^spec/api/v1/.+\.rb$})
  watch(%r{^app/actions/(.+)/(.+)\.rb$})              { |m| "spec/actions/#{m[1]}/#{m[2]}_spec.rb" }
  watch(%r{^spec/actions/(.+)/(.+)\.rb$})
  watch(%r{^lib/(.+)\.rb$})                           { |m| "spec/lib/#{m[1]}_spec.rb" }
end
