
      # Set Hadoop-specific environment variables here.

      # The only required environment variable is JAVA_HOME.  All others are
      # optional.  When running a distributed configuration it is best to
      # set JAVA_HOME in this file, so that it is correctly defined on
      # remote nodes.

      # The java implementation to use.  Required.
      export JAVA_HOME={{java_home}}
      export HADOOP_HOME_WARN_SUPPRESS=1

      # Hadoop home directory
      export HADOOP_HOME=${HADOOP_HOME:-{{hadoop_home}}}

      # Hadoop Configuration Directory

      {# this is different for HDP1 #}
      # Path to jsvc required by secure HDP 2.0 datanode
      export JSVC_HOME={{jsvc_path}}


      # The maximum amount of heap to use, in MB. Default is 1000.
      export HADOOP_HEAPSIZE="{{hadoop_heapsize}}"

      export HADOOP_NAMENODE_INIT_HEAPSIZE="-Xms{{namenode_heapsize}}"

      # Extra Java runtime options.  Empty by default.
      export HADOOP_OPTS="-Djava.net.preferIPv4Stack=true ${HADOOP_OPTS}"


      SHARED_HADOOP_NAMENODE_OPTS="-server -XX:ParallelGCThreads=8 -XX:+UseConcMarkSweepGC -XX:ErrorFile={{hdfs_log_dir_prefix}}/$USER/hs_err_pid%p.log -XX:NewSize={{namenode_opt_newsize}} -XX:MaxNewSize={{namenode_opt_maxnewsize}} -Xloggc:{{hdfs_log_dir_prefix}}/$USER/gc-namenodes-`hostname`.log- -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintGCDateStamps  -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=5 -XX:GCLogFileSize=8k   -XX:+PrintGCDateStamps -XX:CMSInitiatingOccupancyFraction=70 -XX:+UseCMSInitiatingOccupancyOnly -Xms{{namenode_heapsize}} -Xmx{{namenode_heapsize}} -Dhadoop.security.logger=INFO,DRFAS -Dhdfs.audit.logger=INFO,DRFAAUDIT"
      export HADOOP_NAMENODE_OPTS="${SHARED_HADOOP_NAMENODE_OPTS} -XX:OnOutOfMemoryError=\"/usr/hdp/current/hadoop-hdfs-namenode/bin/kill-name-node\" -Dorg.mortbay.jetty.Request.maxFormContentSize=-1 ${HADOOP_NAMENODE_OPTS}"
      export HADOOP_SECONDARYNAMENODE_OPTS="${SHARED_HADOOP_NAMENODE_OPTS} -XX:OnOutOfMemoryError=\"/usr/hdp/current/hadoop-hdfs-secondarynamenode/bin/kill-secondary-name-node\" ${HADOOP_SECONDARYNAMENODE_OPTS}"
      export HADOOP_DATANODE_OPTS="-server -XX:ParallelGCThreads=4 -XX:+UseConcMarkSweepGC -XX:ErrorFile=/var/log/hadoop/$USER/hs_err_pid%p.log -XX:NewSize=200m -XX:MaxNewSize=200m -Xloggc:{{hdfs_log_dir_prefix}}/$USER/gc-datanode-`hostname`.log -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintGCDateStamps  -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=5 -XX:GCLogFileSize=8k   -Xms{{dtnode_heapsize}} -Xmx{{dtnode_heapsize}} -Dhadoop.security.logger=INFO,DRFAS -Dhdfs.audit.logger=INFO,DRFAAUDIT ${HADOOP_DATANODE_OPTS} -XX:CMSInitiatingOccupancyFraction=70 -XX:+UseCMSInitiatingOccupancyOnly"


      # The following applies to multiple commands (fs, dfs, fsck, distcp etc)
      export HADOOP_CLIENT_OPTS="-Xmx${HADOOP_HEAPSIZE}m $HADOOP_CLIENT_OPTS"

      HADOOP_NFS3_OPTS="-Xmx{{nfsgateway_heapsize}}m -Dhadoop.security.logger=ERROR,DRFAS ${HADOOP_NFS3_OPTS}"
      HADOOP_BALANCER_OPTS="-server -Xmx{{hadoop_heapsize}}m ${HADOOP_BALANCER_OPTS}"


      # On secure datanodes, user to run the datanode as after dropping privileges
      export HADOOP_SECURE_DN_USER=${HADOOP_SECURE_DN_USER:-{{hadoop_secure_dn_user}}}

      # Extra ssh options.  Empty by default.
      export HADOOP_SSH_OPTS="-o ConnectTimeout=5 -o SendEnv=HADOOP_CONF_DIR"

      # Where log files are stored.  $HADOOP_HOME/logs by default.
      export HADOOP_LOG_DIR={{hdfs_log_dir_prefix}}/$USER

      # History server logs
      export HADOOP_MAPRED_LOG_DIR={{mapred_log_dir_prefix}}/$USER

      # Where log files are stored in the secure data environment.
      export HADOOP_SECURE_DN_LOG_DIR={{hdfs_log_dir_prefix}}/$HADOOP_SECURE_DN_USER

      # File naming remote slave hosts.  $HADOOP_HOME/conf/slaves by default.
      # export HADOOP_SLAVES=${HADOOP_HOME}/conf/slaves

      # host:path where hadoop code should be rsync'd from.  Unset by default.
      # export HADOOP_MASTER=master:/home/$USER/src/hadoop

      # Seconds to sleep between slave commands.  Unset by default.  This
      # can be useful in large clusters, where, e.g., slave rsyncs can
      # otherwise arrive faster than the master can service them.
      # export HADOOP_SLAVE_SLEEP=0.1

      # The directory where pid files are stored. /tmp by default.
      export HADOOP_PID_DIR={{hadoop_pid_dir_prefix}}/$USER
      export HADOOP_SECURE_DN_PID_DIR={{hadoop_pid_dir_prefix}}/$HADOOP_SECURE_DN_USER

      # History server pid
      export HADOOP_MAPRED_PID_DIR={{mapred_pid_dir_prefix}}/$USER

      YARN_RESOURCEMANAGER_OPTS="-Dyarn.server.resourcemanager.appsummary.logger=INFO,RMSUMMARY"

      # A string representing this instance of hadoop. $USER by default.
      export HADOOP_IDENT_STRING=$USER

      # The scheduling priority for daemon processes.  See 'man nice'.

      # export HADOOP_NICENESS=10

      # Add database libraries
      JAVA_JDBC_LIBS=""
      if [ -d "/usr/share/java" ]; then
      for jarFile in `ls /usr/share/java | grep -E "(mysql|ojdbc|postgresql|sqljdbc)" 2>/dev/null`
      do
      JAVA_JDBC_LIBS=${JAVA_JDBC_LIBS}:$jarFile
      done
      fi

      # Add libraries to the hadoop classpath - some may not need a colon as they already include it
      export HADOOP_CLASSPATH=${HADOOP_CLASSPATH}${JAVA_JDBC_LIBS}

      # Setting path to hdfs command line
      export HADOOP_LIBEXEC_DIR={{hadoop_libexec_dir}}

      # Mostly required for hadoop 2.0
      export JAVA_LIBRARY_PATH=${JAVA_LIBRARY_PATH}

      export HADOOP_OPTS="-Dhdp.version=$HDP_VERSION $HADOOP_OPTS"

      # Fix temporary bug, when ulimit from conf files is not picked up, without full relogin.
      # Makes sense to fix only when runing DN as root
      if [ "$command" == "datanode" ] && [ "$EUID" -eq 0 ] && [ -n "$HADOOP_SECURE_DN_USER" ]; then
      {% if is_datanode_max_locked_memory_set %}
      ulimit -l {{datanode_max_locked_memory}}
      {% endif %}
      ulimit -n {{hdfs_user_nofile_limit}}
      fi

      # Enable ACLs on zookeper znodes if required
      {% if hadoop_zkfc_opts is defined %}
      export HADOOP_ZKFC_OPTS="{{hadoop_zkfc_opts}} $HADOOP_ZKFC_OPTS"
      {% endif %}
