#!/bin/bash
###################################################################
# Title       : DEPENDENCIES.sh
# Description : Installs libraries listed in DEPENDENCIES array 
# Supports    : Ubuntu, Red Hat, CentOS
###################################################################

usage()
{
cat << EOF
usage: sudo $0 <linux-variant>
This script installs all dependencies for UWSIM.

EOF
}

###################################################################
# Dependencies array.  
# Add new dependencies here.
###################################################################
echo "---------------------------------------------------"
echo "Detecting Linux operating system variant."

# Dependencies for all Linux variants...
DEPS_COMMON=(
    ros-hydro-uwsim-bullet 
    ros-hydro-uwsim-osgbullet 
    ros-hydro-uwsim-osgocean 
    ros-hydro-uwsim-osgworks
)

# Dependencies only for RedHat, CentOS, etc.
DEPS_RPM=()

# Dependencies only for Ubuntu
DEPS_DPKG=()

# Dependencies only for ArchLinux
DEPS_PACMAN=()

#Require the script to be run as root
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "This script must be run as root because libraries will be installed."
    usage
    exit
fi

###################################################################
# Determine which package system is being used
# This helps determine which version of linux is being used
###################################################################
# Ubuntu
if which apt-get &> /dev/null; then
    DEPENDENCIES=("${DEPS_COMMON[@]}" "${DEPS_DPKG[@]}")
    echo "This is Ubuntu. Using dpkg."

# OpenSuse, Mandriva, Fedora, CentOs, ecc. (with rpm)
elif which rpm &> /dev/null; then
    DEPENDENCIES=("${DEPS_COMMON[@]}" "${DEPS_RPM[@]}")
    echo "This is Red Hat / CentOS. Using rpm."

# ArchLinux (with pacman)
elif which pacman &> /dev/null; then
    DEPENDENCIES=("${DEPS_COMMON[@]}" "${DEPS_PACMAN}")
    echo "This is ArchLinux. Using pacman."
else
    echo "Can't determine operating system or package system."
    exit
fi

###################################################################
# Determine which packages are missing
###################################################################
echo "Detecting which required packages are not installed."

dep_len=${#DEPENDENCIES[@]}

PKGSTOINSTALL=""
for (( i=0; i < $dep_len; i++))
do
    if which apt-get &> /dev/null; then
	if [[ ! `dpkg -l | grep -w "ii  ${DEPENDENCIES[$i]} "` ]]; then
	    PKGSTOINSTALL=$PKGSTOINSTALL" "${DEPENDENCIES[$i]}
	fi
	# OpenSuse, Mandriva, Fedora, CentOs, ecc. (with rpm)
    elif which rpm &> /dev/null; then
	if [[ `rpm -q ${DEPENDENCIES[$i]}` == "package "${DEPENDENCIES[$i]}" is not installed" ]]; then 
	    PKGSTOINSTALL=$PKGSTOINSTALL" "${DEPENDENCIES[$i]}
	fi
	# ArchLinux (with pacman)
    elif which pacman &> /dev/null; then
	if [[ ! `pacman -Qqe | grep "${DEPENDENCIES[$i]}"` ]]; then
	    PKGSTOINSTALL=$PKGSTOINSTALL" "${DEPENDENCIES[$i]}
	fi
    else
	# If it's impossible to determine if there are missing dependencies, mark all as missing
	PKGSTOINSTALL=$PKGSTOINSTALL" "${DEPENDENCIES[$i]}
    fi
done

###################################################################
# Install missing dependencies.
# First, ask user.
###################################################################
if [ "$PKGSTOINSTALL" != "" ]; then
    echo "The following dependencies are missing:" 
    echo "${PKGSTOINSTALL}"
    echo -n "Want to install them? (Y/n): "
    read SURE
# If user want to install missing dependencies
    if [[ $SURE = "Y" || $SURE = "y" || $SURE = "" ]]; then
    # Debian, Ubuntu and derivatives (with apt-get)
	if which apt-get &> /dev/null; then
	    apt-get install $PKGSTOINSTALL
	# OpenSuse (with zypper)
	elif which zypper &> /dev/null; then
	    zypper in $PKGSTOINSTALL
	# Mandriva (with urpmi)
	elif which urpmi &> /dev/null; then
	    urpmi $PKGSTOINSTALL
	# Fedora and CentOS (with yum)
	elif which yum &> /dev/null; then
	    echo "yum install $PKGSTOINSTALL"
	    yum install $PKGSTOINSTALL
	# ArchLinux (with pacman)
	elif which pacman &> /dev/null; then
	    pacman -Sy $PKGSTOINSTALL
	# Else, if no package manager has been founded
	else
	# Set $NOPKGMANAGER
	    NOPKGMANAGER=TRUE
	    echo "ERROR: impossible to found a package manager in your sistem. Please, install manually ${DEPENDENCIES[*]}."
	fi

        # Check if installation is successful
	if [[ $? -eq 0 && ! $NOPKGMANAGER == "TRUE" ]] ; then
	    echo "All dependencies are satisfied."
        else
	    # Else, if installation isn't successful
	    echo "ERROR: impossible to install some missing dependencies. Please, install manually ${DEPENDENCIES[*]}."
	fi

    else
	# Else, if user don't want to install missing dependencies
	echo "WARNING: Some dependencies may be missing. So, please, install manually ${DEPENDENCIES[*]}."
    fi
else
    echo "All dependencies are installed. No further action is required."
fi




####################################
# Older dependency file commands
####################################
#### 0 for rpm
#### 1 for dpkg
###pkg_mgmt=0
###if [[ ${OS} == "redhat" || ${OS} == "centos" ]]; then
###    pkg_mgmt=0
###elif [[ ${OS} == "ubuntu" ]] 
###then
###    pkg_mgmt=1
###else
###    echo "Invalid Linux variant"
###    usage
###    exit
###fi
###
###case ${pkg_mgmt} in
###    0)
###	for (( i=0; i < $dep_len; i++))
###	do
###	    if [[ `rpm -q ${DEPENDENCIES[$i]}` == "package "${DEPENDENCIES[$i]}" is not installed" ]]; then
###		PKGSTOINSTALL=$PKGSTOINSTALL" "${DEPENDENCIES[$i]}
###	    fi
###	done
###	;;
###    1)
###	if [[ ! `dpkg -l | grep -w "ii  ${DEPENDENCIES[$i]} "` ]]; then
###	    PKGSTOINSTALL=$PKGSTOINSTALL" "${DEPENDENCIES[$i]}
###	fi
###	;;
###    *)
###	echo "invalid"
###	;;
###esac
###
### Determine OS from input...
#os_array=(ubuntu centos redhat)
#os_len=${#os_array[@]}
#### Check for number of expected arguments
###EXPECTED_ARGS=1
###if [ $# -ne $EXPECTED_ARGS ]
###then
###    echo "Invalid number of arguments"
###    usage
###    exit $E_BADARGS
###fi
###
#### Grab the os variant argument
###OS=$@
###
#### Check to see if the OS is supported
###exists=0
###for (( i=0; i < $os_len; i++))
###do
###    if [[ ${os_array[$i]} == ${OS} ]];
###    then
###	exists=1
###	break
###    fi
###done
###
#### If not, throw error message and end script
###if [[ ${exists} -eq 0 ]];
###then
###    echo "Invalid Linux OS Variant"
###    usage
###    exit
###fi
