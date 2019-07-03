#web scraping using Open API in r

library(XML)
library(data.table)
library(stringr)
library(ggplot2)

api_url = "http://openapi.molit.go.kr:8081/OpenAPI_ToolInstallPackage/service/rest/RTMSOBJSvc/getRTMSDataSvcAptTrade?serviceKey="
service_key = "***********************"

locCode <-c("11110","11140","11170","11200","11215","11230","11260","11290","11305","11320","11350","11380","11410","11440","11470","11500","11530","11545","11560","11590","11620","11650","11680","11710","11740")
locCode_nm <-c("종로구","중구","용산구","성동구","광진구","동대문구","중랑구","성북구","강북구","도봉구","노원구","은평구","서대문구","마포구","양천구","강서구","구로구","금천구","영등포구","동작구","관악구","서초구","강남구","송파구","강동구")
datelist <-c("201801","201802","201803","201804","201805","201806","201807","201808","201809","201810","201811","201812")

urllist <- list()
cnt <-0
for(i in 1:length(locCode)){
  for(j in 1:length(datelist)){
    cnt=cnt+1
    urllist[cnt] <-paste0(api_url,service_key, "&LAWD_CD=", locCode[i],"&DEAL_YMD=",datelist[j]) 
  }
} # 지역과 거래년월을 바꿔가면서 url을 urllist 리스트에 저장

total<-list()
for(i in 1:length(urllist)){
  item <- list()
  item_temp_dt<-data.table()
  
  #xml 파일 불러오기
  raw.data <- xmlTreeParse(urllist[i], useInternalNodes = TRUE,encoding = "utf-8")
  rootNode <- xmlRoot(raw.data)  
  
  #두 번째 엘리먼트의 'items' 엘리먼트를 추출해 items에 저장
  items <- rootNode[[2]][['items']]
  
  
  size <- xmlSize(items)
  
  for(i in 1:size){
    item_temp <- xmlSApply(items[[i]],xmlValue) #xml 모든 엘리먼트에 대해 루프를 돌면서 해당 엘리먼트가 가지고 있는 값들 추출
    item_temp_dt <- data.table(price=item_temp[1],
                               con_year=item_temp[2],
                               year=item_temp[3],
                               dong=item_temp[4],
                               aptname=item_temp[5],
                               month=item_temp[6],
                               date=item_temp[7],
                               area=item_temp[8],
                               bungi=item_temp[9],
                               loccode=item_temp[10],
                               floor=item_temp[11])
    item[[i]]<-item_temp_dt #하나의 url에 대한 데이터 추출
  }
  total[[i]]<-rbindlist(item) #전체 url에 대한 데이터 
}

result_apt_data = rbindlist(total)

#지역 코드에 따라 맞는 지역명 열 추가
lapply(locCode,function(x){result_apt_data[loc==x,gu:=locCode_nm[which(locCode==x)]]})





