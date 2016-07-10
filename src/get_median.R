#get Arguments from the Shell Script (input file and output file name)
args<-commandArgs(TRUE)
input.file <- args[1]
output.file <- args[2]

#library graph used to create network graph
#load the library
#library(igraph)

#since the data is not in a proper JSon format we use read table function with comma seperator
venmo.data <- read.table(input.file, sep=",")
#assign column names
colnames(venmo.data) <- c('created_time','target','actor')
#rearrange order
venmo.data <- venmo.data[3:1]

#clean column Actor
venmo.data$actor <- as.character(venmo.data$actor)
venmo.data$actor <- sapply(strsplit(venmo.data$actor, split=': ', fixed=TRUE), function(x) (gsub('.{1}$', '',x[2])))
venmo.data[ venmo.data$actor == '',"actor" ] = NA

#clean column Target
venmo.data$target <- as.character(venmo.data$target)
venmo.data$target <- sapply(strsplit(venmo.data$target, split=': ', fixed=TRUE), function(x) (x[2]))

#clean column Create date
venmo.data$created_time <- as.character(venmo.data$created_time)
venmo.data$created_time <- sapply(strsplit(venmo.data$created_time, split=': ', fixed=TRUE), 
                                  function(x) (x[2]))
venmo.data$created_time <- strptime(venmo.data$created_time, "%Y-%m-%dT%H:%M:%S")

#save as factors
venmo.data$actor <- as.factor(venmo.data$actor)
venmo.data$target <- as.factor(venmo.data$target)

#summary of the input Data
summary(venmo.data)
#as we need to find only the relation between the actor and target we filter the records
#that has null values
#cleansed from the source --not needed now
venmo.data <- venmo.data[complete.cases(venmo.data[,c('actor','target')]),]
summary(venmo.data)


##########################################################
#Graph and Median Function
##########################################################

#buffer list to store valid transaction within window and median list to capture median values.
buffer.list <- NULL
median.list <-NULL

#loop through each and every records
for(i in 1:dim(venmo.data)[1]){
  
  print(paste0('Transaction : ',i))

  #get the maximum time frame uptill the processing records
  Max.TimeFrame <- max(venmo.data$created_time[1:i])
  buffer.list$timediff <- NULL
  buffer.list <- rbind(buffer.list,venmo.data[i,])
  buffer.list$timediff <- as.numeric(buffer.list$created_time - Max.TimeFrame,units="secs")
  #filter records based on the window
  buffer.list <- buffer.list[buffer.list$timediff>-60,]
  #print(buffer.list)
  
  #list names to capture all the names and the count
  list.names<-NULL
  
  #to create a Graph string with relations
  #graph.string <- 'G <- make_graph(~ '
  
  #loop through all the valid customers
  for(i in 1:dim(buffer.list)[1]){
    list.names <- rbind(list.names,as.character(buffer.list[i,1]))
    list.names <- rbind(list.names,as.character(buffer.list[i,2]))
    
    #if(max(dim(buffer.list)[1]) == i){
    #  graph.string <- paste0(graph.string,'\'',as.character(buffer.list[i,1]),'\'-\'',as.character(buffer.list[i,2]),'\')')
    #}
    #else{
    #  graph.string <- paste0(graph.string,'\'',as.character(buffer.list[i,1]),'\'-\'',as.character(buffer.list[i,2]),'\',')
    #}
  }

  #print(graph.string)
  #print(list.names)
  table.names <-table(list.names)
  #print(table.names)
  #table.names.df <- as.data.frame(table.names)
  #table.names.df$GraphName <-paste0('\'',table.names.df$list.names,'\n(',table.names.df$Freq,')\'') 
  #table.names.df$list.names <- paste0('\'',table.names.df$list.names,'\'')
  #replace names with names plus count eg abc as abc(2)
  #for(i in 1:dim(table.names.df)[1]){
  #  graph.string <- gsub(table.names.df$list.names[i],table.names.df$GraphName[i],graph.string)
  #}
  #print(graph.string)
  
  #parse the graph string and plot the graph
  #eval(parse(text=graph.string))
  #plot(G)#,vertex.size = 50,edge.width=2)
  
  #Capture the median value  
  median.list <- rbind(median.list,round(median(table.names),2))
  
  print('Median Calculated.')
  
  print('\n#################################################################\n')
}

#write the final output to the output file
write.table(median.list, file=output.file,row.names=FALSE, col.names=FALSE, sep=",")
