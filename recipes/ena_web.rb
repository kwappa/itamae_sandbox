# open HTTP / HTTPS
execute '/sbin/iptables -I INPUT 5 -p tcp --dport https -j ACCEPT'
execute '/sbin/iptables -I INPUT 5 -p tcp --dport http -j ACCEPT'
execute '/sbin/service iptables save'
execute '/etc/init.d/iptables restart'

# nginx
execute 'resister yum repository for nginx' do
  command 'rpm -ivh http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm'
end

service 'nginx'
package 'nginx'
