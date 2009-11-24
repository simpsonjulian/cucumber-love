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


Given /^a[n]{0,1} (\S+) (\w+) in (.*)$/ do |kind,type,path|
  if type == 'file'
    @config_file = File.join(path, kind)
    File.exists?(path).should be_true  
  end
  if type == 'dir'
    @config_dir = path
    Dir.entries(path).size.should > 2  
  end
end


When /^I generate it$/ do
  dest_file = File.join(@tmp_server_root,@file)
  FileUtils.mkdir_p(@tmp_server_root)

  server_root = @tmp_server_root # the ERB template needs this

  template = ERB.new(File.read(@template_file))
  File.open(dest_file,'w+') {|f| f.write(template.result(binding)) }
  File.size(dest_file).should > 0 
end

Then /^there should be a file called (.*) in (.*)$/ do |name, dir|
  @config_file = name
  File.exists?(File.join(@tmp_dir,dir,name)).should be_true
end

Then /^it should be a syntactically valid (.*) (.*)$/ do |kind, type|
  checks = { 
  'apache' => "/usr/sbin/httpd -d #{@tmp_server_root} -t -f #{@config_file}",
  'sudoers' => "/usr/sbin/visudo -c -f #{@config_file}",
  'postfix' => "postconf -c  #{@config_dir} > /dev/null",
  'nginx' => "nginx -t -c #{@config_file}",
  'named' => "named-checkconf #{@tmp_dir}/#{@server_root}/#{@config_file}",
  'monit' => "monit -t -c #{@config_file}" }
  check = checks[kind]
  raise "there's no check for #{kind}" if check.nil?
  puts "DEBUG: #{check}"
  system(check).should be_true

end

When /^copy files from (.*) to the tmp root$/ do |dir|
  tmp_root = File.join(@tmp_dir, dir)
  FileUtils.mkdir_p(tmp_root)
  FileUtils.cp_r("#{dir}/.",tmp_root)
end


