library(Boruta)
library(readr)
library(tidyverse)
library(dplyr)

setwd('C:/Users/lab_user/Desktop/data')

trainData <- read_csv('train.csv')
summary(trainData)

# feature에 _ 를 공백으로 변경
names(trainData) <- gsub('_', ' ', names(trainData))

# NA 위치 확인
trainData[which(is.na(trainData)),]

trainData[trainData==''] = NA # blank 값 확인
trainData = trainData[complete.cases(trainData), ] # 결측치 행 모두 삭제 

convert <- c(2:6, 11:13)
trainData[,convert] = lapply(trainData[,convert], factor) # 범주형 변수를 factor 타입으로 변환

# boruta 적용 
boruta.train = Boruta(`Loan Status`~., data=trainData, doTrace=2)
print(boruta.train)

plot(boruta.train, xlab = "", xaxt = "n")
lz<-lapply(1:ncol(boruta.train$ImpHistory),function(i)
  boruta.train$ImpHistory[is.finite(boruta.train$ImpHistory[,i]),i])


names(lz) <- colnames(boruta.train$ImpHistory)
Labels <- sort(sapply(lz,median))
axis(side = 1,las=2,labels = names(Labels),
     at = 1:ncol(boruta.train$ImpHistory), cex.axis = 1)


# 최종 Boruta
# tentative 변수에 대한 중요성을 결정하기 위해 TentativeRoughFix 함수를 사용함. 
# TentativeRoughFix Boruta 실행횟수가 적가나 shadow 변수를 생성하는데 있어서 운이 좋지 않았거나, 다소 까다로운 데이터 셋의 경우 tentative 변수를 남길 수 있는데 각 tentative 변수에 대한 판단을 위해 간단한 검증을 수행하는 것이다. 
final_boruta = TentativeRoughFix(boruta.train)
print(final_boruta)

plot(final_boruta, xlab = "", xaxt = "n")
lz<-lapply(1:ncol(final_boruta$ImpHistory),function(i)
  final_boruta$ImpHistory[is.finite(final_boruta$ImpHistory[,i]),i])
names(lz) <- colnames(final_boruta$ImpHistory)
Labels <- sort(sapply(lz,median))
axis(side = 1,las=2,labels = names(Labels),
     at = 1:ncol(final_boruta$ImpHistory), cex.axis = 1)

getSelectedAttributes(final_boruta, withTentative = F) # 최종적으로 중요하다고 판단된 변수는 총 7개! 



