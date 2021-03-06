# This simulates gene expression that are only present in one outlier cell.

library(scran)
source("../functions.R")

set.seed(200)
detect.tab <- "detect_outlier.txt"
above.tab <- "above_outlier.txt"
new.file <- TRUE
ngenes <- 1000
nspikes <- 50

for (ncells in c(100, 200, 500, 1000)) { 
    for (fold in c(0.01, 0.1, 1)) { 
        scaling <- matrix(1, ngenes, ncells)
        chosen.genes <- 1:50
        scaling[chosen.genes, 1] <- fold
        scaling[chosen.genes, -1] <- 0

        collected.d <- collected.a <- vector("list", 20)
        for (it in seq_len(20)) {
            sim.genes <- sampleCounts(ngenes=ngenes, nsamples=ncells, scaling=scaling)
            sim.spikes <- sampleCounts(ngenes=nspikes, nsamples=ncells, scaling=1)
            counts <- rbind(sim.genes, sim.spikes)
            is.spike <- seq_len(nspikes) + ngenes

            my.env <- detectHVGs(counts, is.spike, chosen.genes)
            collected.d[[it]] <- my.env$output
            collected.a[[it]] <- my.env$above
        }
        
        write.table(data.frame(Ncells=ncells, FC=fold, rbind(colMeans(do.call(rbind, collected.d)))),
                    file=detect.tab, append=!new.file, col.names=new.file, row.names=FALSE, sep="\t", quote=FALSE)
        write.table(data.frame(Ncells=ncells, FC=fold, rbind(colMeans(do.call(rbind, collected.a)))),
                    file=above.tab, append=!new.file, col.names=new.file, row.names=FALSE, sep="\t", quote=FALSE)
        new.file <- FALSE
    }
}

