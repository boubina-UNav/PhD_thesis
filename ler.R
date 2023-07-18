# Clean all variables
rm(list=ls())

# Read and clean data frame
taboa <- read.table("./Results/clean.csv",sep=',')
nomes=rep("ola",ncol(taboa))
for (i in 1:ncol(taboa)) nomes[i] <- as.character(taboa[1,i])
colnames(taboa) <- nomes
taboa <- taboa[2:dim(taboa)[1],]
rownames(taboa) <- NULL
taboa <- droplevels(taboa)
rm(i,nomes)

# Convert to matrix
colAdh <- which(names(taboa)=="Adhesive")
valores <- matrix(0,dim(taboa)[1],dim(taboa)[2]-1)
for (i in 1:dim(valores)[2]) valores[,i] <- as.numeric(as.character(taboa[,i+as.numeric(i>=colAdh)]))
colnames(valores) <- colnames(taboa)[1:dim(taboa)[2]!=colAdh][1:9]
rm(i,colAdh)

# Prepare indexes
colTair <- grep("Tair",colnames(valores))
colQadh <- grep("Qadh",colnames(valores))
colPair <- grep("mbar",colnames(valores))
colH <- grep("h\\(mm)",colnames(valores))
colF <- grep("f\\(Hz)",colnames(valores))
colD <- grep("d\\(mm)",colnames(valores))

# Regroup and plot data
niveis <- sort(as.numeric(as.character(levels(taboa[,]$`P(mbar)`))))
for (m in levels(taboa$Adhesive)) {
  indAdh <- taboa$Adhesive==m
  Rates <- sort(as.numeric(as.character(levels(droplevels(taboa[indAdh,]$`Qadh(g/s)`)))))
  if (length(Rates)!=3) next
  Temps <- sort(as.numeric(as.character(levels(droplevels(taboa[indAdh,]$`Tair (C)`)))))
  for (l in Rates) {
    indices <- which(valores[,colQadh]==l&indAdh)
    # Prepare colours
    nivel <- sort(as.numeric(as.character(levels(droplevels(taboa[indices,]$`P(mbar)`)))))
    cores <- rep(1,length(indices))
    for (i in 1:length(indices)) {
      cores[i] <- which(niveis==valores[indices[i],colPair])
    }
    corLenda <- rep(1,length(nivel))
    for (i in 1:length(nivel)) {
      corLenda[i] = which(niveis==nivel[i])
    }
    # Prepare pch
    formas <- rep(2,length(indices))
    # formas <- rep(1,length(indices))
    # for (i in 1:length(indices)) {
    #   #formas[i] <- which(Temps==valores[indices[i],colTair])
    #   # NA_integer_ shows no symbol. CCE: {2,17}. E: {1,19}.
    #   if (which(Temps==valores[indices[i],colTair])==1) {
    #     if (taboa$Nozzle[indices[i]]=='E') formas[i] <- 1
    #     else formas[i] <- 2
    #   }
    #   else {
    #     if (taboa$Nozzle[indices[i]]=='E') formas[i] <- 19
    #     else formas[i] <- 17
    #   }
    # }
    
    # Plot frequency
    minFreq = min(valores[,colF])
    maxFreq = max(valores[,colF])
    minDist = min(valores[,colH])
    maxDist = max(valores[,colH])
    plot(valores[indices,colH],valores[indices,colF],xlab="h (mm)",ylab="f (Hz)",col=cores,pch=formas,cex=1.5,ylim=c(minFreq,maxFreq),xlim=c(minDist,maxDist))
    legend('topright',legend=nivel,col=corLenda,pch=2,bg="transparent",title="Pair (mbar)")
    titulo <- as.character(taboa[indices[1],]$Adhesive)
    titulo <- paste(titulo,", Qadh",l,"g/s")
    title(titulo)
    #Plot diameter
    minDiam = min(valores[,colD])
    maxDiam = max(valores[,colD])
    plot(valores[indices,colH],valores[indices,colD],xlab="h (mm)",ylab="d (mm)",col=cores,pch=formas,cex=1.5,ylim=c(minDiam,maxDiam),xlim=c(minDist,maxDist))
    legend('bottomright',legend=nivel,col=corLenda,pch=2,bg="transparent",title="Pair (mbar)")
    title(titulo)
  }
}
rm(i,l,niveis,nivel,titulo)





