%define gem_name little-plugger
%define gem_cache_dir /opt/puppetlabs/puppet/share/gems

Summary:   LittlePlugger is a module that provides Gem based plugin management
Name:      openvox-agent-%{gem_name}
Version:   1.1.4
Release:   2%{?dist}
Group:     Development/Languages
License:   MIT
URL:       https://github.com/TwP/little-plugger
Source0:   https://rubygems.org/gems/%{gem_name}-%{version}.gem
Requires:  openvox-agent >= 8
Requires:  openvox-agent < 9
Requires:  /opt/puppetlabs/puppet/bin/gem
BuildArch: noarch
Obsoletes: puppet-agent-%{gem_name}

%description
LittlePlugger is a module that provides Gem based plugin management. By extending
your own class or module with LittlePlugger you can easily manage the loading and
initializing of plugins provided by other gems.

%prep
%setup -q -c -T
cp -a %{SOURCE0} ./

%build

%install
mkdir -p %{buildroot}%{gem_cache_dir}
cp -a ./%{gem_name}-%{version}.gem %{buildroot}%{gem_cache_dir}

%files
%{gem_cache_dir}/%{gem_name}-%{version}.gem

%post
/opt/puppetlabs/puppet/bin/gem install --local %{gem_cache_dir}/%{gem_name}-%{version}.gem >/dev/null

%preun
if [ $1 == 0 ]; then  # uninstall
  /opt/puppetlabs/puppet/bin/gem uninstall -x -v %{version} %{gem_name} >/dev/null
else  # upgrade
  # Only uninstall on upgrade if there are multiple gem versions installed, as the package
  # is probably changing version, not only undergoing a release bump
  if ! /opt/puppetlabs/puppet/bin/gem list %{gem_name} | grep %{gem_name} | grep -q '(%{version})'; then
    /opt/puppetlabs/puppet/bin/gem uninstall -x -v %{version} %{gem_name} >/dev/null
  fi
fi

%changelog
* Mon Jul 27 2026 Lennart Betz <lbetz@prefork.de> - 1.1.4-2
- Rename package, remove OpenVox 7 support
* Fri Aug 30 2024 Lennart Betz <lennart.betz@netways.de> - 1.1.4-1
- Release 1.1.4
