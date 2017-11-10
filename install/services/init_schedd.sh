#!/bin/bash
#################################################################################
#  This script is used to create the necessary directories for secondary schedds.
#  The directories of the primary schedd (LOCAL_DIR, LOG) are assumed to exist already
#  The config file must be queried for the correct schedd, e.g.:
#  condor_config_val  -host $(hostname -s) -subsystem SCHEDD -local-name SCHEDDGLIDEINS2 SCHEDDGLIDEINS2.SCHEDD_LOG
########################################################################
function logit {
  echo "$1"
}
#---------------
function logerr {
  logit "ERROR: $1";exit 1
}
#--------------
function usage {
  echo "
Usage: $PGM 

  This script uses condor_config_val to determine the necessary directories 
  for multiple secondary schedds.

  The condor_config_val script should be in your path and the CONDOR_CONFIG 
  environmental variable set correctly.
"
}
#-----------------
function validate {
  if [ "$(type condor_config_val &>/dev/null;echo $?)" != "0" ];then
    logerr "The condor_config_val script is not in your PATH and is required to do this."
  fi

  CONFIG_VAL="condor_config_val -h $(hostname -s)"
  OWNER=$($CONFIG_VAL CONDOR_IDS 2>/dev/null)
  if [ ! -n "$OWNER" ]; then
    logerr "Error determining who should own the Condor-related directories.
Either create a "condor" account, or set the CONDOR_IDS environment
variable to the valid uid.gid pair that should be used by Condor."
  fi

}
#-------------------------
function validate_attrs {
  local s_name=$1
  local att_name=$2
  local dir=$($CONFIG_VAL -subsystem SCHEDD -local-name $s_name $att_name 2>/dev/null)
  if [ -z "$dir" ];then
    logerr "Undefined Condor attribute (SCHEDD/$s_name): $att_name"
  fi
}
#-------------------------
function create_dirs {
  local s_name=$1
  local att_name=$2
  local dir=$($CONFIG_VAL -subsystem SCHEDD -local-name $s_name $att_name)
  logit "  $att_name: $dir "
  if [  -d "$dir" ];then
    logit "  ... already exists"
  else  
    mkdir $dir;rtn=$?
    if [ "$rtn" != "0" ];then
      logerr "Permissions problem creating directory as owner: $OWNER"
    fi 
    logit "  ... created"
  fi
  chown $OWNER $dir;rtn=$?
  if [ "$rtn" != "0" ];then
    logerr "Permissions problem changing ownership to owner: $OWNER"
  fi 
  chmod 755 $dir
}
#-------------------------
function validate_all {
  for schedd in $schedds
  do
    if [ "$schedd" = "+" ];then
      continue
    fi
    logit "Validating schedd: $schedd"
    for a  in $attrs
    do
      attr=$schedd.$a
      validate_attrs $schedd $attr
    done
  done
}
#-------------------------
function create_all {
  for schedd in $schedds
  do
    if [ "$schedd" = "+" ];then
      continue
    fi
    logit
    logit "Processing schedd: $schedd"
    for a  in $attrs
    do
      attr=$schedd.$a
      validate_attrs $schedd $attr
      create_dirs $schedd $attr
    done
  done
}
#------------------------
#### MAIN ##############################################
PGM=$(basename $0)

validate

# List of secondary schedds
schedds="$($CONFIG_VAL  DC_DAEMON_LIST)"
# LOCAL_DIR is for the main condor/schedd, LOCAL_DIR_ALT is for secondary schedds
# LOG not included since it is common
attrs="LOCAL_DIR_ALT LOG EXECUTE SPOOL LOCK"
#attrs=" EXECUTE SPOOL LOCK"

validate_all
create_all

exit 0

