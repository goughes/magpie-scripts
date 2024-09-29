Running RHIPE

Note: If it has been a while since you ran this experiment, some of your files might have been scratched. It's best to remove the entire experiment directory in `/scratch/negishi/yourusername/hdfsoverlustre` to ensure correct setup.

1. `sbatch magpie.sbatch-srun-hadoop-lustre-hdfs` 
2. Run these (a006 and job 15961698 are assumed):
```
ssh a006
export JAVA_HOME="/apps/spack/negishi/apps/openjdk/11.0.17_8-gcc-12.2.0-gifyh2f"
export HADOOP_HOME="/home/wwtung/hadoop-3.3.6"
export HADOOP_CONF_DIR="/tmp/wwtung/hadoop/magpietest/15961698/hadoop/conf"
```
3. Run these to further set HADOOP_LIBS for magpie
```export HADOOP_LIBS=$HADOOP_HOME/etc/hadoop:$HADOOP_HOME/share/hadoop/common/lib/:$HADOOP_HOME/share/hadoop/common/:$HADOOP_HOME/share/hadoop/hdfs:$HADOOP_HOME/share/hadoop/hdfs/lib/:$HADOOP_HOME/share/hadoop/hdfs/:$HADOOP_HOME/share/hadoop/yarn/lib/:$HADOOP_HOME/share/hadoop/yarn/:$HADOOP_HOME/share/hadoop/mapreduce/lib/:$HADOOP_HOME/share/hadoop/mapreduce/:$HADOOP_HOME/contrib/capacity-scheduler/
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

7. CPMA script

These are done in the shell environment. Copy the script from GDSP's Depot space to your own scratch disk to perform experiments. Swap `wwtung` with your own username:

```
cd /depot/gdsp/data/CPMA/MAGPIE_Lustre_HDFS_Run
cp performance.R /scratch/negishi/wwtung/CPMA/MAGPIE_Lustre_HDFS_Run
```

```
cd /scratch/negishi/wwtung/CPMA/MAGPIE_Lustre_HDFS_Run
Rscript performance.R
```
8. Next time use magpie-hadoop-lustre-hdfs again, you might need to remove the in_use lock file.
```
rm /scratch/negishi/wwtung/hdfsoverlustre//magpie.hdfs_in_use
```
