#This is the class for managing NRPE client 

class nrpe (


#We take this value from osfamily YAML
$nrpe_packages = hiera_array('nrpe::packages', undef),
$nrpe_path                = hiera('nrpe_path'),
$service_name             = hiera('nrpe::service'),
#END

#We take this values from FQDN yaml file, if the institute name is not set as a FACT the nrpe::enable will not work.
#It will work only after the location is set on the client side
$nrpe_enable              = hiera('nrpe::enable'),
$nrpe_service_ensure      = hiera('nrpe::service_ensure'),
$nrpe_service_enable      = hiera('nrpe::service_status'),
#END

)
#Start coding
{

#Install the packages based on host YAML
$multi = [$nrpe_packages]  
package { $multi:
    ensure => $nrpe_enable,
  }

#END


#If the packages are installed and the configuration file is set, than the service will be started
#It the package is not installed don't do anything
service { $service_name:
    ensure    => $nrpe_service_ensure,
    enable    => $nrpe_service_enable,
    name      => $service_name,
    hasstatus => true,
    require   => [
                  Package[$multi],
                  File["$nrpe_path"],


],
  }

#END

#If the package is installed, autoconfigure the service than notify the service
#After notification the service will be reloaded automaticaly
file { $nrpe_path:
  ensure  => $file,
  content => template('nrpe/nrpe.cfg.erb'),
  require => Package[$multi],
  notify => Service["$service_name"],

}
#END




}#END of module
