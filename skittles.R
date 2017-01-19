# Set working directory, load data files, load libraries
setwd("~/Dropbox/R/Skittles")
skittles<-read.csv("skittles.csv")
library(reshape2)
library(ggplot2)

# Set up an official palette
# Skittles Palette obtained by: http://www.color-hex.com/color-palette/1146
#   Colors:     Sberry    Orange    Lemon     Apple     Grape
skipalette<-c("#c0043f","#e64808","#f1be02","#048207","#441349")

# Rename data headers, and grab the overall mean
names(skittles)<-c("Pak","Strawberry","Orange","Lemon","Apple","Grape")
netmean<-mean(c(skittles$Strawberry,skittles$Orange,skittles$Lemon,skittles$Apple,skittles$Grape))

# Summarize data into frame "skitsum" for the final plot.
skitsum<-data.frame("flavor"=names(skittles)[2:6],
                    "mean"=sapply(skittles[,2:6],mean),
                    "sd"=sapply(skittles[,2:6],sd))
skitsum$flavor <- factor(skitsum$flavor,
                         c("Strawberry","Orange","Lemon","Apple","Grape"))

# Generate "skitbin". "skitbin" will allow us to plot a neat "Raw Results" diagram in the first plot
skitmelt<-melt(skittles,id="Pak")
skitbin<-data.frame("Pak"=NA,"variable"=NA,"value"=NA)
for(n in 1:nrow(skitmelt)){
  skitbin<-rbind(skitbin,skitmelt[rep(n,skitmelt$value[n]),])   }
skitbin<-skitbin[2:nrow(skitbin),]
skitbin$variable <- factor(skitbin$variable,
                         c("Strawberry","Orange","Lemon","Apple","Grape"))
rm(n);rm(skitmelt)

# Convert raw data into a "Raw results" pictogram via "skitbin"
ggplot(skitbin,aes(x=Pak,y=variable))+
  geom_jitter(aes(fill=variable),height=5/16,width=5/16,shape=21,size=3)+
  geom_tile(color="grey75",alpha=0)+
  scale_fill_manual("Flavor",values=skipalette)+
  guides(fill="none")+
  scale_x_continuous(breaks=1:36,minor_breaks=seq(.5,36.5,1))+
  scale_y_discrete(limits=rev(levels(melt(skittles,id="Pak")$variable)))+
  labs(title="Skittles Counts",
       subtitle="Raw Results",
       x="Pack Number",y="Flavor",
       caption="created by /u/zonination")+
  theme_bw()+
  theme(panel.grid=element_blank())
ggsave("skit1.png",height=4,width=14,dpi=100,type="cairo-png")

# Convert raw data into heatmap, mildly more pleasing than "skitbin"
ggplot(melt(skittles,id="Pak"),aes(x=Pak,y=variable))+
  geom_tile(aes(fill=variable,alpha=value),color="white")+
  geom_text(aes(label=value),size=3)+
  scale_fill_manual("Flavor",values=skipalette)+
  guides(alpha="none",fill="none")+
  scale_x_continuous(breaks=1:36,minor_breaks=NULL)+
  scale_y_discrete(limits=rev(levels(melt(skittles,id="Pak")$variable)))+
  labs(title="Skittles Counts",
       subtitle="Raw Results Converted into Heatmap",
       x="Pack Number",y="Flavor",
       caption="created by /u/zonination")+
  theme_bw()
ggsave("skit2.png",height=4,width=14,dpi=100,type="cairo-png")

# Convert data into stacked bar chart. Yet even more pleasing.
ggplot(melt(skittles,id="Pak"),aes(Pak,value))+
  geom_bar(stat="identity",aes(fill=variable),alpha=.8)+
  scale_fill_manual("Flavor",values=skipalette)+
  labs(title="Skittles Counts",
      subtitle="Stacked Bar Chart",
      x="Pack Number",y="Skittle Count",
      caption="created by /u/zonination")+
  scale_x_continuous(breaks=1:36,minor_breaks=NULL)+
  theme_bw()
ggsave("skit3.png",height=5,width=8,dpi=100,type="cairo-png")

# Plot data in a violinplot, with added dotplot for effect.
ggplot(melt(skittles,id="Pak"),aes(variable,value))+
  geom_violin(aes(fill=variable),alpha=.8)+
  geom_dotplot(binaxis="y",stackdir="center",aes(fill=variable))+
  scale_fill_manual("Flavor",values=skipalette)+
  guides(fill="none")+
  labs(title="Skittles Flavor Distribution",
       subtitle="Violinplot with added Dotplot",
       x="Flavor",y="Skittle Count",
       caption="created by /u/zonination")+
  scale_y_continuous()+
  geom_hline(yintercept=netmean,linetype=4)+
  theme_bw()
ggsave("skit4.png",height=5,width=8,dpi=100,type="cairo-png")

# Plot the summary statistics: Mean +/- 95% conf
ggplot(skitsum,aes(x=flavor,y=mean))+
  geom_bar(stat="identity",aes(fill=flavor),alpha=.8,color="black")+
  geom_errorbar(aes(ymax=mean+1.96*sd,ymin=mean-1.96*sd),width=0.2,size=1,alpha=.5)+
  scale_fill_manual("Flavor",values=skipalette)+
  guides(fill="none")+
  labs(title="Skittles Flavor Distribution",
       subtitle="Statistical Summary of Skittles Flavors",
       x="Flavor",y="Mean Skittle Count\nError bars are 95% Confidence Intervals",
       caption="created by /u/zonination")+
  geom_hline(yintercept=netmean,linetype=4)+
  theme_bw()
ggsave("skit5.png",height=5,width=8,dpi=100,type="cairo-png")