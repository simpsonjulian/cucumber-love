require 'fileutils'
require 'spec/expectations'

Before do
  @tmp_dir = 'tmp'
end

Given /^a config file template (.*) in (.*)$/ do |file, server_root|
  @server_root = server_root
  @tmp_server_root = File.join('tmp',@server_root)
  @template_file = File.join('templates',server_root,file)
  @file = file
  File.exists?(@template_file).should be_true
end

When /^I generate it$/ do
  dest_file = File.join(@tmp_server_root,@file)
  FileUtils.mkdir_p(@tmp_server_root)

  server_root = @server_root # the ERB template needs this

  template = ERB.new(File.read(@template_file))
  File.open(dest_file,'w+') {|f| f.write(template.result(binding)) }
  File.size(dest_file).should > 0 
end

Then /^there should be a file called (.*) in (.*)$/ do |name, dir|
  @config_file = name
  File.exists?(File.join(@tmp_dir,dir,name)).should be_true
end

And /^it should be valid$/ do
  system("/usr/sbin/httpd -d #{@tmp_server_root} -t -f #{@config_file}").should be_true
end

