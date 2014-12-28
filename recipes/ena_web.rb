# nginx
execute 'resister yum repository for nginx' do
  command 'rpm -ivh http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm'
end

service 'nginx'
package 'nginx'
