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

boruta_df = attStats(final_boruta)
class(boruta_df) ## [1] "data.frame"
print(boruta_df)# attStats 함수는 boruta 알고리즘의 결과를 데이터 프레임으로 만들어주고, 각 변수에 대한 중요도와 hist 수, 판단 결과를 생성한다. 

### paramater
# - maxRuns : 랜덤포레스트 최대 실행 횟수, default = 100, tentative 변수가 남으면 횟수를 늘려도 됨. 
# - doTrace: 0 = 추적하지 않음, 1 = 변수라 판정되면 결과를 즉각 보고함, 2 = 각 반복에서 hit+1을 추가로 보고함. 
# - holdHistoy : True(dafault) = 중요도를 구하는 모든 과정을 저장하며 ImpHistory 요소를 통해 출력됨. 출력된 결과는 각 반복에 대한 변수의 중요도이며 기각된 변수, 즉 중요한 변수는 -inf로 표시됨. 

