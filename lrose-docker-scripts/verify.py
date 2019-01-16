#!/usr/bin/env python

#
# Check the system for common issues known to trip lrose builds
# Bruno Melli 07-20-18
#

from __future__ import print_function
import subprocess
import re

# --------------------------------------------------------------------------------------
# Class hierarchy to deal with the native package manager (rpm, dpkg, ...)
# --------------------------------------------------------------------------------------

class Pkg:

    def __init__(self):
        pass

    def get_installed(self):    # get a list of installed packages
        pass

class Dpkg(Pkg):                # dpkg based systems (Debian, Ubuntu, Mint, ...)
    
    def __init__(self):
        pass

    def get_installed(self):
        installed = set()
        out, err =  subprocess.Popen(['dpkg', '-l'],
                                     stdout = subprocess.PIPE).communicate()
        lines = out.splitlines()
        for line in lines:
            m = re.search('^ii\s+(\S+)', line)
            if m != None:
                pkg = m.group(1)
                installed.add(pkg)
        return installed

class Rpm(Pkg):

    def get_installed(self):    # RPM based systems (redhat, SuSE, ...)
        installed = set()
        out, err =  subprocess.Popen(['rpm', 'qa'],
                                     stdout = subprocess.PIPE).communicate()
        lines = out.splitlines()
        for line in lines:
            m = re.search('^([^.]+)\.', line)
            if m != None:
                pkg = m.group(1)
                installed.add(pkg)
        return installed

# --------------------------------------------------------------------------------------
# Class hierarchy to deal with the various distros (Debian, Ubuntu, Mint, Centos, Fedora, ...
# --------------------------------------------------------------------------------------
    
class Distro:

    def factory(distro):
        if distro == 'debian':
            return Debian()
        elif distro == 'ubuntu':
            return Ubuntu()
        elif distro == 'centos':
            return Centos()
        elif distro == 'fedora':
            return Fedora()
        else:
            raise AssertionError('Unknown distribution:' + distro)
            return None

    factory = staticmethod(factory)
    
    def get_installed(self):
        pass
    
    def get_missing_build(self):
        return self.required_build - self.installed

    def verify_version(self, version):
        pass

    def version_str_to_float(self, str):      # d.d.d.d -> d.d as a float
        m = re.search('^(\d+(\.\d+)?)', str)
        if m != None:
            return float(m.group(1))
        
class Ubuntu(Distro):
    
    def __init__(self):
        self.required_build = {
            'libbz2-dev', 'libx11-dev', 'libpng12-dev', 'libfftw3-dev',
            'libjasper-dev', 'qtbase5-dev', 'git',
            'gcc', 'g++', 'gfortran', 'libfl-dev',
            'automake', 'make', 'libtool', 'pkg-config',
            'libexpat1-dev', 'python'
            'libqt5gui5', 'libqt5core5a', 'qt5-default',
            'libx11-6', 'libfreetype6'
        }
        self.package_mgr = Dpkg()
        self.installed = self.package_mgr.get_installed()

    def verify_version(self, str):
        version = Distro.version_str_to_float(self, str)
        if version > 17.0:
            print('lrose build has only been tested on Ubuntu 17.04.x. ' +
                  ' The package list for ' + str + ' might have changed.')
        
   
class Debian(Distro):

    def __init__(self):
        self.required_build = {
            'libbz2-dev', 'libx11-dev', 'libpng12-dev', 'libfftw3-dev',
            'libjasper-dev', 'qtbase5-dev', 'git',
            'gcc', 'g++', 'gfortran', 'libfl-dev',
            'automake', 'make', 'libtool', 'pkg-config',
            'libexpat1-dev', 'python'
            'libqt5gui5', 'libqt5core5a', 'qt5-default',
            'libx11-6', 'libfreetype6'
        }
        self.package_mgr = Dpkg()
        self.installed = self.package_mgr.get_installed()

    def verify_version(self, str):
        version = Distro.version_str_to_float(self, str)
        if version > 8:
            print('lrose build has only been tested on Debian 8. ' +
                  ' The package list for ' + str + ' might have changed.')
        
class Fedora(Distro):
    
    def __init__(self):
        self.required_build = {
            'rsync', 'gcc', 'gcc-gfortran', 'gcc-c++',
            'make', 'wget', 'expat-devel', 'm4', 'jasper-devel',
            'flex-devel', 'zlib-devel', 'libpng-devel',
            'bzip2-devel', 'qt5-qtbase-devel', 'fftw3-devel',
            'xorg-x11-server-Xorg', 'xorg-x11-xauth', 'xorg-x11-apps',
        }
        
        self.package_mgr = Rpm()
        self.installed = self.package_mgr.get_installed()
        
class Centos(Distro):

    def __init__(self):
        self.required_build = {
            'rsync', 'gcc', 'gcc-gfortran', 'gcc-c++',
            'make', 'wget', 'expat-devel', 'm4', 'jasper-devel',
            'flex-devel', 'zlib-devel', 'libpng-devel',
            'bzip2-devel', 'qt5-qtbase-devel', 'fftw3-devel',
            'xorg-x11-server-Xorg', 'xorg-x11-xauth', 'xorg-x11-apps',
        }
        
        self.package_mgr = Rpm()
        self.installed = self.package_mgr.get_installed()


# --------------------------------------------------------------------------------------
# Takes care of finding info about the os configuration (distro, version, ...)
# --------------------------------------------------------------------------------------        

class OsConfig:
    
    def __init__(self):

        self.fields = {}

        with open('/etc/os-release') as fp:
            for line in fp:
                m = re.search('^([^=]+)=(.+)', line)
                left = m.group(1)
                right = m.group(2).replace('"', '')
                self.fields[left] = right

    def get_field(self, str):
        return self.fields[str]

# --------------------------------------------------------------------------------------
# Take care of checking commands
# --------------------------------------------------------------------------------------

class Cmd:
    
    @staticmethod
    def cmd_path(cmd):
        try:
            out = subprocess.check_output(['which', cmd]).strip()
        except:
            out = None
        return out

    @staticmethod
    def cmd_version(cmd):
        try:
            out = subprocess.check_output([cmd, '--version'], stderr=subprocess.STDOUT).strip()
        except:
            out = None
        return out

# --------------------------------------------------------------------------------------
# Misc support functions
# --------------------------------------------------------------------------------------

def check_python():
    print('')
    python_path = Cmd.cmd_path('python')
    print('python_path: ' + python_path)
    
    if python_path == None:
        print('python is required for building lrose, but was not found in your path')
    else:
        python_version = Cmd.cmd_version('python')
        print('python version: ' + python_version)
        
        m = re.search('^(\d+\.\d+?)', python_version)
        if m != None:
            version = float(m.group(1))
            if version >= 3.0:
                print('lrose currently only builds with python 2.7.x. You have ' + python_version)
                print('Change your PATH to point to a 2.7.x version before building')

def check_qmake():
    print('')
    qmake_path = Cmd.cmd_path('qmake')
    print('qmake path: ' + qmake_path)
    
    if qmake_path == None:
        print('qmake is required for building lrose, but was not found in your path')
    else:
        qmake_version = Cmd.cmd_version('qmake')
        print('qmake version: ' + qmake_version)
        m = re.search('Using Qt version (\d+\.\\d+?)', qmake_version)
        if m != None:
            version = float(m.group(1))
            if version < 5.0:
                print('lrose requires Qt 5.x. You are currently using ' + version)
                print('if you have 5.x installed, change your PATH so that ' +
                      'the 5.x version of qmake is found first')
        
# --------------------------------------------------------------------------------------
# Main
# --------------------------------------------------------------------------------------

config = OsConfig()
distro = Distro.factory(config.get_field('ID'))
distro.verify_version(config.get_field('VERSION_ID'))

missing_build = distro.get_missing_build()
if len(missing_build) > 0:
    print('The following packages needed to build and run lrose components are missing:')
    for pkg in missing_build:
        print(pkg)

check_python()
check_qmake()
