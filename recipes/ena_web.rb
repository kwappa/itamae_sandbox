# open HTTP / HTTPS
execute '/sbin/iptables -I INPUT 5 -p tcp --dport https -j ACCEPT'
execute '/sbin/iptables -I INPUT 5 -p tcp --dport http -j ACCEPT'
execute '/sbin/service iptables save'
execute '/etc/init.d/iptables restart'

# nginx
execute 'resister yum repository for nginx' do
  command 'rpm -ivh http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm'
  not_if 'type nginx'
end

service 'nginx'
package 'nginx'

# libralies to build rbenv / ruby
package 'git'
package 'gcc'

# rbenv
include_recipe "rbenv::system"

RBENV_ROOT = "/usr/local/rbenv"
RBENV_INIT_COMMAND ="export RBENV_ROOT=#{RBENV_ROOT} ; export PATH='#{RBENV_ROOT}/bin:${PATH}' ; eval \"$(rbenv init --no-rehash -)\""

execute 'initialize rbenv' do
  command "echo '#{RBENV_INIT_COMMAND}' >> /etc/bashrc ; source /etc/bashrc"
  not_if 'type rbenv'
end
