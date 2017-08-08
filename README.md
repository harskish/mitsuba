# Building Mitsuba on the CSC Taito supercluster
This guide is based partially on the [RenderToolbox build guide][rbguide] (24.5.2017).

Before starting you need a CSC account, which can be acquired at the [signup page][cscsig]. All the following actions are performed on a taito-shell compute node, which can be accessed by running
```sh
$ ssh username@taito-shell.csc.fi
```
or by starting an interactive shell from taito-login:
```sh
$ ssh username@taito.csc.fi
[username@taito-login ~]$ sinteractive 
```
The taito-shell environment is used as to not put a load on the login node.


## Taito file transfer
Source code and other files are typically stored in **$HOME** (or possiby **$USERAPPL**).
There are several ways of transferring files to Taito:

- **Git** over https works by default on Taito. In order to use Git over ssh, you need to update the `~/.ssh/config` file to make sure that the correct ssh certificate is used.

- The **[CSC Scientist's User Interface][cscsui]** is a web service that, among other things, supports uploading of single files to Taito. In case of multiple files or folders, another method is preferred.

- Taito is a standard Linux environment, and as such, **SCP/Rsync** or similar file transfer tools can be used.

More information on Taito file transfer:
<https://research.csc.fi/csc-guide-moving-data-between-csc-and-local-environment>


## Mitsuba dependencies
Being a shared computing environment, Taito doesn't support installing software through a package manager. This means that most dependencies have to be built from source.
This guide will install all libraries into **$HOME/libs**, although this path can be freely customized.

Before starting, make sure you copy the appopriate build config from the build folder to the Mitsuba root, as we'll be making changes to the copied config file. For more details, check the Mitsuba documentation.

At the time of writing, Mitsuba has the following strict dependencies:
- Boost
- Xerces
- Eigen
- Qt 4
- GLEW

The following are optional dependencies:
- OpenEXR + IlmBase
- FFTW
- COLLADA DOM

This guide will cover all libraries, except for COLLADA DOM (covered by the RenderToolbox guide).
The GUI and its dependencies can be disabled by commenting out the following lines:
- File ‘SConstruct’:
	```
	build('src/mtsgui/SConscript', ['mainEnv', ...
	```
- File ‘build/SConscript.install’:
	```
	if hasQt:
		install(distDir, ['mtsgui/mtsgui'])
	```

### Build environment setup
The first step is to check if any of the dependencies are availabe through the [module system][cscmod] by running
```sh
$ module spider module_name
```
Out of the listed dependencies, only boost is available through the moduel system. Since `boost 1.54` is recommended for Mitsuba, we'll setup the environment accordingly:
```sh
$ module spider boost/1.54    # dependencies: gcc/4.7.2 and intelmpi/4.1.0
$ module load gcc/4.7.2
$ module load intelmpi/4.1.0
$ module load boost/1.54
```
It is recommended to put the last three lines into `~/.bash_profile` so that one doesn't end up compiling libraries with different versions of gcc by accident (e.g. after opening a new shell).

Even though the module system updates `LD_LIBRARY_PATH`, Mitsuba ended up linking against an old version of boost by default.
To prevent this, check boost location with `echo $BOOST_ROOT`, and add it to `config.py`:
```
BOOSTINCLUDE = ['/appl/opt/boost/gcc-4.7.2/intelmpi-4.1.0/boost-1.54/include']
BOOSTLIBDIR = ['/appl/opt/boost/gcc-4.7.2/intelmpi-4.1.0/boost-1.54/lib']
```

### Building the libraries

##### Xerces
Upload [xerces-c-3.1.4.tar.gz][xerces] to `~/libs/build`.
```sh
$ tar zxf xerces-c-3.1.4.tar.gz && cd xerces-c-3.1.4
$ ./configure --prefix=$HOME/libs/xerces/
$ cd src/ && make   # build only libraries
$ cd .. && make install
```
Add to config:
```
XERCESLIBDIR = ['/homeappl/home/username/libs/xerces/lib'],
XERCESINCLUDE = ['/homeappl/home/username/libs/xerces/include'],
```

##### IlmBase
Upload [ilmbase-2.2.0.tar.gz][oexr] to `~/libs/build`.
```
$ ./configure --prefix=$HOME/libs/ilmbase
$ make
$ make install
```

##### OpenEXR
Upload [openexr-2.2.0.tar.gz][oexr] to `~/libs/build`. Make sure that the version matches that of IlmBase.
```
$ tar zxf openexr-2.2.0.tar.gz && cd openexr-2.2.0
$ export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/libs/ilmbase/lib
$ PKG_CONFIG_PATH=$HOME/libs/ilmbase/lib/pkgconfig ./configure --prefix=$HOME/libs/openexr
$ make
$ make install
```

Update config:
```
OEXRINCLUDE = ['/homeappl/home/username/libs/openexr/include/OpenEXR', '/homeappl/home/username/libs/ilmbase/include/OpenEXR'']
OEXRLIBDIR = ['/homeappl/home/username/libs/openexr/lib', '/homeappl/home/username/libs/ilmbase/lib']
```

##### Qt4
Taito has Qt4 and Qt5 pre-installed into `usr/lib64/qt{4/5}`. Mitsuba's build scripts detect the correct version automatically.

##### Eigen3
```
$ cd ~/libs/build
$ wget 'http://bitbucket.org/eigen/eigen/get/3.3.3.tar.gz' (use newest)
$ tar zxf 3.3.3.tar.gz
$ mv eigen-eigen-67e894c6cd8f eigen-3.3.3
$ mkdir -p ~/libs/eigen3/Eigen && cp -r eigen-3.3.3/Eigen $HOME/libs/eigen3/
```
Set `EIGENINCLUDE = ['/homeappl/home/username/libs/eigen3']` in config.

##### GLEW
Mitsuba requires GLEW with MX support. This excludes `glew 2.X`, since they don't support GLEW-MX.
Upload [glew 1.13.0][glew] to `~/libs/build` and extract contents.
```
$ export GLEW_DEST=$HOME/libs/glew
$ make CFLAGS.EXTRA="-DGLEW_MX -fPIC" LDFLAGS.GL="-lGLU -lGL -lXext -lX11"
$ make install.all
```
Update config with
```
GLINCLUDE = ['/homeappl/home/username/libs/glew/include']
GLLIBDIR = ['/homeappl/home/username/libs/glew/lib64']
```

##### FFTW3
```
$ cd ~/libs/build
$ wget ftp://ftp.fftw.org/pub/fftw/fftw-3.3.6-pl2.tar.gz
$ tar zxf fftw-3.3.6-pl2.tar.gz
$ ./configure --prefix=$HOME/libs/fftw/ --enable-threads CFLAGS='-g -O2 -fPIC' CXXFLAGS='-g -O2 -fPIC'
$ make
$ make install
```
Update config:
```
FFTWLIBDIR = ['/homeappl/home/username/libs/fftw/lib']
FFTWINCLUDE = ['/homeappl/home/username/libs/fftw/include']
```

### Building Mitsuba

Mitsuba can now be built by running `scons` in the Mitsuba root directory. If everything is setup correctly, the Mitsuba libraries and binaries should be built and copied over to mitsuba/dist. Check `config.log` in case of any issues.

##### Fix missing -lIlmImf, -lHalf
The Taito environment didn't manage to link mitsuba.o correctly without manually adding the line `env.Append(LIBS=['IlmImf', 'Half'])` to the end of src/libcore/SConscript. This is an unfortunate hack that shouldn't be required.

### Running Mitsuba

Mitsuba links against some shared libraries by default. Since they are installed locally in a non-standard directory, they need to be added to the library search path:
`export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/libs/glew/lib64:$HOME/libs/xerces/lib:$HOME/libs/ilmbase/lib:$HOME/libs/openexr/lib`

Add `source mitsuba/setpath.sh` to `~/.bash_profile` to add the Mitsuba binaries to `PATH`.

Run Mitsuba with `mitsuba /path/to/scene.xml`.

### Building on Aalto Triton
See the [Triton build instructions](./triton_build.txt).

[//]: # (These are reference links used in the body of this note and get stripped out when the markdown processor does its job. There is no need to format nicely because it shouldn't be seen. Thanks SO - http://stackoverflow.com/questions/4823468/store-comments-in-markdown-syntax)

[cscsig]: <https://sui.csc.fi/signup>
[rbguide]: <https://github.com/RenderToolbox/RenderToolbox3/wiki/Building-Mitsuba-on-CentOS>
[cscsui]: <https://sui.csc.fi/>
[cscmod]: <https://research.csc.fi/csc-guide-environment-module-systems>
[xerces]: <http://xerces.apache.org/mirrors.cgi>
[oexr]: <http://www.openexr.com/downloads.html>
[glew]: <http://glew.sourceforge.net/>