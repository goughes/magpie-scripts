options(java.parameters = "-Xmx4000m") # use this line when you have >100M data
library(Rhipe)
#N = number of observasation
rhinit()
rhoptions(zips = "/user/wwtung/bin/R.Pkg.tar.gz")
rhoptions(runner = "sh ./R.Pkg/library/Rhipe/bin/RhipeMapReduce.sh")

rawnetworkhome <- "/ceph/wceres/wwtung/rawnetworkfs/"
rawnetworktmp <- paste0(rawnetworkhome,"tmp")

#----------------------------------------------------------------------
n <- 6
N <- 2^n
m.c = c(5,4)
v <- 1
V <- 2^v
P <- 2^v - 1
rep.c <- 1:3
sleep <- 1
## 64mb blocksize
blocksize.c <- c( 2^26, 2^27, 2^28)
#----------------------------------------------------------------------
map1 <- expression({
  for (r in map.values){
    set.seed(r)
    value <- matrix(c(rnorm(M*P), sample(c(0,1), M, replace=TRUE)), ncol=P+1)
    rhcollect(r, value)
  }
})
#---------------------------------------------------------------------
timing <- data.frame() 
for( blocksize in blocksize.c){
  ### 1. Simulate Data 
  for(m in m.c){
    dir.dm  <- paste0(rawnetworkhome,"CEPH_Run/results/","m",m,sep="")
    mr1 <- rhwatch(
      map      = map1,
      input    = c(2^(n-m),2),
      output   = dir.dm,
      jobname  = dir.dm,
      mapred   = list(
        # do not time out
        mapreduce.task.timeout=0,
        mapreduce.job.maps=2,
        mapreduce.job.reduces=0,
        dfs.blocksize = blocksize
      ),
      parameters = list(M = 2^m, P = P),
      readback = FALSE
    )
  }
  ### 2. O time 
  type <- "O"
  map2 <- expression({})
  for( rep in rep.c ){
    for(m in m.c){
      dir.dm  <- paste0(rawnetworkhome,"CEPH_Run/results/","m",m,sep="")
      dir.nf  <- paste0(rawnetworkhome,"CEPH_Run/Otime/","m",m,sep="")
      mr2 <- rhwatch(
        map      = map2,
        input    = dir.dm,
        output   = dir.nf,
        jobname  = dir.dm,
        mapred   = list(
          mapred.reduce.tasks=0,
          dfs.blocksize = blocksize
        ),
        parameters = list(P = P),
        noeval   = TRUE,
        readback = FALSE
      )
      t  <- as.numeric(system.time({rhex(mr2, async=FALSE)})[3])
      t  <- data.frame(rep=rep,bl=blocksize,n=n,m=m,v=v,type=type,t=t)
      timing <- rbind(timing,t)  
      Sys.sleep(time=sleep)
    }
    print(timing)  
    
    ### 3. T time 
    map3 <- expression({
      for (v in map.values) {
        value = glm.fit(v[,1:P],v[,P+1],family=binomial())$coef
        rhcollect(1, value)
      }
    })
    reduce3 <- expression(
      pre = {
        v = rep(0,P) 
        nsub = 0
      },
      reduce = {
        v = v + 
          colSums(matrix(unlist(reduce.values), 
                         ncol=P, byrow=TRUE)) 
        nsub = nsub + length(reduce.values)
      },
      post = {
        rhcollect(reduce.key, v/nsub)
      }
    )  
    type <- "T"
    for(m in m.c){
      dir.dm  <- paste0(rawnetworkhome,"CEPH_Run/results/","m",m,sep="")
      dir.gf  <- paste0(rawnetworkhome,"CEPH_Run/Ttime/","m",m,sep="")
      mr3 <- rhwatch(
        map      = map3,
        reduce   = reduce3,
        input    = dir.dm,
        output   = dir.nf,
        mapred   = list(
          mapreduce.job.reduces=1,
          dfs.blocksize = blocksize
        ),
        parameters = list(P=P),
        jobname    = dir.gf,
        noeval     = TRUE
      )
      t <- as.numeric(system.time({rhex(mr2, async=FALSE)})[3])
      t = data.frame(rep=rep,bl=blocksize,n=n,m=m,v=v,type=type,t=t)
      timing = rbind(timing,t)
      print(timing)  
    }      
  }
}

save(timing, file="performance.RData")
#---------------------------------------------------------------------
