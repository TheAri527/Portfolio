####################
# Adam Imran       #
# ANLY 503         #
# July 2020        #
####################

####### AI: Code Modified from  Dr. Ami Gates

## AI: Apply Twitter Cred ####################################################
consumerKey = 'TLyweWBCgiqK76giEct0hbFLz'
consumerSecret = 'FuvVvyegapnAUTZ3BzNwVvLgAfWpOyCpqVbCEvxEY8koVbFNpr'
access_Token = '701894802359635968-dvoWlKw2C1gZWwfysqI1UwI6z8qhnY5'
access_Secret = 'GqKcFkTf0xZkGVZ6QZiKWiUlUl5C2tb1eZsGXvFrR1kuR'

requestURL='https://api.twitter.com/oauth/request_token'
accessURL='https://api.twitter.com/oauth/access_token'
authURL='https://api.twitter.com/oauth/authorize'
#################################################################################

### AI: import necessary packages ##############################################
library(networkD3)
library(arules)
library(rtweet)
library(twitteR)
library(ROAuth)
library(jsonlite)
library(rjson)
library(tokenizers)
library(tidyverse)
library(plyr)
library(dplyr)
library(ggplot2)
library(syuzhet)
library(stringr)
library(arulesViz)
library(igraph)
#################################################################################

##############  AI: Mine for hashtage Using twittR ###############################
setup_twitter_oauth(consumerKey,consumerSecret,access_Token,access_Secret)
Search<-twitteR::searchTwitter("#ceramics",n=15)
(Search_DF <- twListToDF(Search))
TransactionTweetsFile = "ceramic_TweetResults.csv"
(Search_DF$text[1])
#################################################################################


## AI: Append tokenized words to file ###########################################
## Start the file
Trans <- file(TransactionTweetsFile)
## Tokenize to words 
Tokens<-tokenizers::tokenize_words(
  Search_DF$text[1],stopwords = stopwords::stopwords("en"), 
  lowercase = TRUE,  strip_punct = TRUE, strip_numeric = TRUE,
  simplify = TRUE)

## Write tokens
cat(unlist(Tokens), "\n", file=Trans, sep=",")
close(Trans)

## Append remaining lists of tokens into file
## Recall - a list of tokens is the set of words from a Tweet
Trans <- file(TransactionTweetsFile, open = "a")
for(i in 2:nrow(Search_DF)){
  Tokens<-tokenize_words(Search_DF$text[i],stopwords = stopwords::stopwords("en"), 
                         lowercase = TRUE,  strip_punct = TRUE, simplify = TRUE)
  cat(unlist(Tokens), "\n", file=Trans, sep=",")
}
close(Trans)
#################################################################################

## AI: remove links and turn to df###################
## Read the transactions data into a dataframe
TweetDF <- read.csv(TransactionTweetsFile, 
                    header = FALSE, sep = ",")
head(TweetDF)
(str(TweetDF))
## Convert all columns to char 
TweetDF<-TweetDF %>%
  mutate_all(as.character)
(str(TweetDF))
# We can now remove certain words
TweetDF[TweetDF == "t.co"] <- ""
TweetDF[TweetDF == "rt"] <- ""
TweetDF[TweetDF == "http"] <- ""
TweetDF[TweetDF == "https"] <- ""
####################################################

## AI: Remove the numbers and thin the tweets ###
MyDF<-NULL
MyDF2<-NULL
for (i in 1:ncol(TweetDF)){
  MyList=c() 
  MyList2=c() # each list is a column of logicals ...
  MyList=c(MyList,grepl("[[:digit:]]", TweetDF[[i]]))
  MyDF<-cbind(MyDF,MyList)  ## create a logical DF
  MyList2=c(MyList2,(nchar(TweetDF[[i]])<4 | nchar(TweetDF[[i]])>9))
  MyDF2<-cbind(MyDF2,MyList2) 
  ## TRUE is when a cell has a word that contains digits
}
##################################################

## AI: For all TRUE, replace with blank ###
TweetDF[MyDF] <- ""
TweetDF[MyDF2] <- ""
(head(TweetDF,10))
###########################################

## AI: Now we save the dataframe using the write table command # 
write.table(TweetDF, file = "ceramic_UpdatedTweetFile.csv", col.names = FALSE, 
            row.names = FALSE, sep = ",")
TweetTrans <- read.transactions("ceramic_UpdatedTweetFile.csv", sep =",", 
                                format("basket"),  rm.duplicates = TRUE)
##############################################################

## AI: Create the Rules  - Relationships ########################
TweetTrans_rules = arules::apriori(TweetTrans, 
                                   parameter = list(support=.01, conf=.15, minlen=2))
## Sort by Lift
SortedRules_lift <- sort(TweetTrans_rules, by="lift", decreasing=TRUE)
inspect(SortedRules_lift[1:50])

TweetTrans_rules<-SortedRules_lift[1:50]
inspect(TweetTrans_rules)
##############################################################

## AI: Convert the rules to data frame ###########################
Rules_DF2<-DATAFRAME(TweetTrans_rules, separate = TRUE)
(head(Rules_DF2))
str(Rules_DF2)
## Convert to char
Rules_DF2$LHS<-as.character(Rules_DF2$LHS)
Rules_DF2$RHS<-as.character(Rules_DF2$RHS)
## Remove all {}
Rules_DF2[] <- lapply(Rules_DF2, gsub, pattern='[{]', replacement='')
Rules_DF2[] <- lapply(Rules_DF2, gsub, pattern='[}]', replacement='')
###################################################################

## AI: USING LIFT get top 30 rules  ###############################
Rules_L<-Rules_DF2[c(1,2,5)]
names(Rules_L) <- c("SourceName", "TargetName", "Weight")
####################################################################

## AI: Apply the superior rules to Lift ###############################
Rules_Sup<-Rules_L
#########################################################################

## AI: Construct edgelist and create the graph #########################
(edgeList<-Rules_Sup)
MyGraph <- igraph::simplify(igraph::graph.data.frame(edgeList, directed=TRUE))
#########################################################################

## AI: Plot the network ##################################################
plot(MyGraph)
#########################################################################
