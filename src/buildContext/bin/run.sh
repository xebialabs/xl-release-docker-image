#!/bin/sh
#
# Shell script to start the XL Release Server
#

absdirname ()
{
  _dir="`dirname \"$1\"`"
  cd "$_dir"
  echo "`pwd`"
}

resolvelink() {
  _dir=`dirname "$1"`
  _dest=`readlink "$1"`
  case "$_dest" in
  /* ) echo "$_dest" ;;
  *  ) echo "$_dir/$_dest" ;;
  esac
}

# Get Java executable
if [ -z "$JAVA_HOME" ] ; then
  JAVACMD=java
else
  JAVACMD="${JAVA_HOME}/bin/java"
fi

# Get XL Release server home dir
if [ -z "$XL_RELEASE_SERVER_HOME" ] ; then
  self="$0"
  if [ -h "$self" ]; then
    self=`resolvelink "$self"`
  fi
  BIN_DIR=`absdirname "$self"`
  XL_RELEASE_SERVER_HOME=`dirname "$BIN_DIR"`
elif [ ! -d "$XL_RELEASE_SERVER_HOME" ] ; then
  echo "Directory $XL_RELEASE_SERVER_HOME does not exist"
  exit 1
fi

cd "$XL_RELEASE_SERVER_HOME"

wrapper_conf_file=$XL_RELEASE_SERVER_HOME/conf/xlr-wrapper-linux.conf

# Get JVM options
XL_RELEASE_SERVER_DEFAULT_OPTS=`sed -n 's/^wrapper.java.additional.\([0-9]*\) *= *\(.*\)/\2/p' "$wrapper_conf_file" | tr '\n' ' '`
XL_RELEASE_SERVER_OPTS="$XL_RELEASE_SERVER_DEFAULT_OPTS $XL_RELEASE_SERVER_OPTS"

# Build XL Release server classpath
classpath_dirs=`sed -n 's/^wrapper.java.classpath.\([0-9]*\)=\(.*[^*]\)$/\2/p' "$wrapper_conf_file" | tr '\n' ':' | sed 's/.$//'`

XL_RELEASE_SERVER_CLASSPATH="${classpath_dirs}"

all_files_to_list=`sed -n 's/^wrapper.java.classpath.\([0-9]*\)=\(.*\)\/\*$/\2 /p' "$wrapper_conf_file" | tr '\n' ' '`
all_files_to_list="$all_files_to_list -name '*.jar'"
all_files=`echo $all_files_to_list | xargs find`
for each in $all_files
do
  if [ -f $each ]; then
    case "$each" in
      *.jar)
        XL_RELEASE_SERVER_CLASSPATH=${XL_RELEASE_SERVER_CLASSPATH}:${each}
        ;;
    esac
  fi
done

expandedPluginDirs=`find plugins/* -maxdepth 0 -type d 2> /dev/null`
for sub_dir in $expandedPluginDirs
do
  if [ -d $expandedPluginDir ]; then
    XL_RELEASE_SERVER_CLASSPATH=${XL_RELEASE_SERVER_CLASSPATH}:${sub_dir}
  fi
done

# Run XL Release server
exec $JAVACMD $XL_RELEASE_SERVER_OPTS -classpath "${XL_RELEASE_SERVER_CLASSPATH}" com.xebialabs.xlrelease.XLReleaseBootstrapper "$@"
