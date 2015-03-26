threshold = 0.9
spdata=read.csv("C:/Users/Nadaraj/Google Drive/MTech/FYP/Cor/datafull_removed_na.csv")
attach(spdata)

cor.mat=cor(spdata, use="pairwise", method = "pearson")

results <- data.frame(v1=character(0), v2=character(0), cor=numeric(0), stringsAsFactors=FALSE)
for(i in 1:nrow(cor.mat))
{
	j=1
	while(j<i)
	{
		if(!is.na(cor.mat[i,j]) && (cor.mat[i,j] > threshold || cor.mat[i,j] < -threshold ))
		{
		results <- rbind(results, data.frame(v1=rownames(cor.mat)[i], v2=colnames(cor.mat)[j], cor=cor.mat[i,j]))
		}
	j=j+1
	}
}

print(results)

write.csv(results, file = "C:/Users/Nadaraj/Google Drive/MTech/FYP/Cor/results.csv")