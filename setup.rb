require 'rubygems'
require 'bundler/setup'
Bundler.require

INSTANCE_ID = 'i-97023f8e'

ec2 = Aws::EC2::Client.new(region: 'ap-northeast-1')
instance_info = ec2.describe_instances.reservations[0].instances[0]
ip_address = instance_info.public_ip_address

puts `bundle exec itamae ssh -h #{ip_address} -p 22 -u root -i .aws/devenv-key.pem recipes/ena_web.rb`
