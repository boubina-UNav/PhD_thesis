taboa <- read.table("united.csv",sep=',')
indSi <- which(grepl(".bmp",taboa[,1]))
indNom <- which(grepl(".csv",taboa[,1])) 

nSi <- length(indSi)
Adh <- rep("adhesive",nSi)
Tadh <- 1:nSi
Tair <- Tadh
Qadh <- Tadh

anotando <- 1
indNom <- c(indNom,dim(taboa)[1]+1)
for (i in 1:(length(indNom)-1)) {
  nome <- as.character(taboa[indNom[i],1])
  numero <- indNom[i+1] - indNom[i] - 2
  indices <- anotando:(anotando+numero-1)
  anotando <- anotando + numero
  
  Tadh[indices] <- rep(155,numero)
  Tair[indices] <- rep(120,numero)
  if (grepl("/Q1/",nome)) Qadh[indices] <- rep(1,numero)
  else if (grepl("/Q2/",nome)) Qadh[indices] <- rep(2,numero)
  else Qadh[indices] <- rep(3,numero)
  if (grepl("PHC7194",nome)) Adh[indices] <- rep("Lunatack PHC 7194",numero)
  else Adh[indices] <- rep("Lunatack D 7214",numero)
}

taboa <- cbind(taboa[indSi,-1],Adh,Tadh,Qadh,Tair)
colnames(taboa) <- c('P(mbar)', "h(mm)", "f(Hz)", "std(f)(Hz)", "d(mm)", "std(d)(mm)", "Adhesive", "Tadh(C)", "Qadh(g/s)", "Tair (C)")
limpa <- taboa[as.character(taboa$`std(f)(Hz)`)!="NaN",]
row.names(limpa) <- NULL
#for (i in 1:6) limpa[,i] <- as.numeric(as.character(limpa[,i]))
write.table(limpa,"clean.csv",sep=',',row.names=FALSE)
