qa_beat_23<-setDT(year4)[,.(freq=sum(OffenseCount)),by=c('Beat')]

qa_beat_22<-setDT(year3)[,.(freq=sum(OffenseCount)),by=c('Beat')]

compare<-merge(qa_beat_23, qa_beat_22, all=TRUE,by=c('Beat'))

exp_miss<-compare[is.na(freq.x),.(Beat)]
new_not<-compare[is.na(freq.y),.(Beat)]

print(exp_miss)
print(new_not)