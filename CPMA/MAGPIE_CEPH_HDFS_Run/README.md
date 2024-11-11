Running RHIPE

Note: If it has been a while since you ran this experiment, some of your files might have been scratched. It's best to remove the entire experiment directory in `/ceph/wceres/yourusername/hdfsoverlustre` to ensure correct setup. 

This folder is only visible after running a script to start the backend cluster. 

1. `sbatch magpie.sbatch-srun-hadoop-ceph-hdfs` 
2. Run these (a283 and job 19626228 are assumed):
```
ssh a283
export JAVA_HOME="/apps/spack/negishi/apps/openjdk/11.0.17_8-gcc-12.2.0-gifyh2f"
export HADOOP_HOME="/home/wwtung/hadoop-3.3.6"
export HADOOP_CONF_DIR="/tmp/wwtung/hadoop/magpietest/19626228/hadoop/conf"
```
3. Run these to further set HADOOP_LIBS for magpie
```
export HADOOP_LIBS=$HADOOP_HOME/etc/hadoop:$HADOOP_HOME/share/hadoop/common/lib/:$HADOOP_HOME/share/hadoop/common/:$HADOOP_HOME/share/hadoop/hdfs:$HADOOP_HOME/share/hadoop/hdfs/lib/:$HADOOP_HOME/share/hadoop/hdfs/:$HADOOP_HOME/share/hadoop/yarn/lib/:$HADOOP_HOME/share/hadoop/yarn/:$HADOOP_HOME/share/hadoop/mapreduce/lib/:$HADOOP_HOME/share/hadoop/mapreduce/:$HADOOP_HOME/contrib/capacity-scheduler/
```
4. Get this (just once):
```
cp /depot/gdsp/data/CPMA/MAGPIE_Run/Rhipe_0.78.0_hadoop-2.tar.gz .
```
5. In a006 run
```
module purge
module load r
export PATH=/depot/itap/goughes/protobuf-2.5.0/bin:$PATH
export LD_LIBRARY_PATH=/depot/itap/goughes/protobuf-2.5.0/lib:$LD_LIBRARY_PATH 
export LIBRARY_PATH=/depot/itap/goughes/protobuf-2.5.0/include:$LIBRARY_PATH
export PKG_CONFIG_PATH=/depot/itap/goughes/protobuf-2.5.0/lib/pkgconfig:$PKG_CONFIG_PATH
```
6. Then start R and followed basically 10.b and beyond in https://github.com/ClimateLearning/Rhipe_Installation/tree/master/wceres.rcac to install the new Rhipe (just once, and swap wwtung with your user name).

If you have already installed Rhipe in another experiment, consider to go directly to the `library(Rhipe)` step.

```
R
```

Following commands are R commands:

```
install.packages("rJava")
install.packages("testthat")
install.packages("Rhipe_0.78.0_hadoop-2.tar.gz", repos=NULL, type="source")
```

These can be done after quit and restart R, to quit: 
```
q()
```
To restart R:
```
R
```

R commands:
```
library(Rhipe)
rhinit()

rhmkdir("/user/wwtung/bin")
hdfs.setwd("/user/wwtung/bin")
bashRhipeArchive("R.Pkg")
```

```
library(Rhipe)
rhinit()
rhoptions(zips = "/user/wwtung/bin/R.Pkg.tar.gz")
rhoptions(runner="sh ./R.Pkg/library/Rhipe/bin/RhipeMapReduce.sh")
```

The last step will copy all detected R libraries to `/ceph/wceres/wwtung/R.Pkg/library`.


7. CPMA script

These are done in the shell environment. Copy the script from GDSP's Depot space to your own scratch disk to perform experiments. Swap `wwtung` with your own username:

```
mkdir /ceph/wceres/wwtung/CPMA
mkdir /ceph/wceres/wwtung/CPMA/MAGPIE_CEPH_HDFS_Run
cd /depot/gdsp/data/CPMA/MAGPIE_CEPH_HDFS_Run
cp performance.R /ceph/wceres/wwtung/CPMA/MAGPIE_CEPH_HDFS_Run
```

Note this version of `performance.R` has output pointed to the Ceph storage.


```
cd /ceph/wceres/wwtung/CPMA/MAGPIE_CEPH_HDFS_Run
Rscript performance.R
```

#### Footnotes
```
wwtung@a283.negishi:[MAGPIE_CEPH_HDFS_Run] $ $HADOOP_HOME/bin/hadoop fs -ls /
Found 3 items
drwx------   - wwtung wwtung          0 2024-09-29 22:34 /ceph
drwxrwx---   - wwtung wwtung          0 2024-09-29 22:46 /tmp
drwx------   - wwtung wwtung          0 2024-09-29 22:05 /user

wwtung@a283.negishi:[MAGPIE_CEPH_HDFS_Run] $ $HADOOP_HOME/bin/hadoop fs -ls /ceph
Found 1 items
drwx------   - wwtung wwtung          0 2024-09-29 22:34 /ceph/wceres
wwtung@a283.negishi:[MAGPIE_CEPH_HDFS_Run] $ $HADOOP_HOME/bin/hadoop fs -ls /ceph/wceres
Found 1 items
drwx------   - wwtung wwtung          0 2024-09-29 22:34 /ceph/wceres/wwtung

wwtung@a283.negishi:[MAGPIE_CEPH_HDFS_Run] $ $HADOOP_HOME/bin/hadoop fs -ls /tmp
Found 25 items
-rw-------   3 wwtung wwtung         69 2024-09-29 22:45 /tmp/rhipe-temp-params-078c69830710f1bb8034094c2c41d39a
-rw-------   3 wwtung wwtung         69 2024-09-29 22:45 /tmp/rhipe-temp-params-1c5a9c95131fc6408d4bb3f5b2c50e95
-rw-------   3 wwtung wwtung         69 2024-09-29 22:40 /tmp/rhipe-temp-params-2abc77af81e4f68e003d4619671db3e5

```

More on temp files

```
wwtung@a283.negishi:[tmp] $ pwd
/tmp/wwtung/hadoop/magpietest/19626228/hadoop/scratch/tmp
wwtung@a283.negishi:[tmp] $ ls 
jetty-a283-19888-hadoop-yarn-common-3_3_6_jar-_-any-18054412607365848418
jetty-a283-50070-hdfs-_-any-817009911237868260
jetty-a283-50090-secondary-_-any-18060710032352221288
jetty-a283-8088-hadoop-yarn-common-3_3_6_jar-_-any-6776069867355761212

```

Rescue output file from Ceph into Depot:

```
wwtung@a283.negishi:[MAGPIE_CEPH_HDFS_Run] $ cp performance.RData /depot/wwtung/data/performance.ceph.hdfs.RData
```