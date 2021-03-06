//+------------------------------------------------------------------+
//|                                                   NO_BRAINER.mq4 |
//|                                                      FULLOUTFOOL |
//|                                             michael.john.orlando |
//+------------------------------------------------------------------+

// standard deviation tells weather to trade bolanger bands.. range   or EMA... trend
//https://www.youtube.com/watch?v=lYzn_mEpTyg

#property copyright "FULLOUTFOOL"
#property link      "michael.john.orlando"
#property version   "1.00"
#property strict

input int    //--- input parameters  
   Fast_EMA,
   Medium_EMA,
   Slow_EMA,
   StopLoss, 
   TakeProfit,
   St_Dev_period;
input double
   St_Dev_above,
   Risk_Percent;  
   
int LONG_ticket,SHORT_ticket;
double lot_size = ((Risk_Percent/100)*AccountBalance()/StopLoss);
bool sell_WAIT=false,buy_WAIT=false;         // only one open per dubble cross
bool long_current=false,short_current=false;  // long or short currently open 
int run_count = 0;
static int BARS;

//+------------------------------------------------------------------+
//| NewBar function                                                  |
//+------------------------------------------------------------------+
bool IsNewBar(){
   if(BARS!=Bars(_Symbol,_Period)){
            BARS=Bars(_Symbol,_Period);
            return(true);
   }
   return(false);
}  
//+------------------------------------------------------------------+
//| Can the robot start checking yet?                                |
//| ... dont want it to start untill a crossover has happend         |
//+------------------------------------------------------------------+
bool start_condition(double F_EMA,double M_EMA,double S_EMA){
   if(F_EMA>M_EMA && M_EMA>S_EMA){ // system wants to open long
            // buy_WAIT will change to true
            return(true);
   }
   //sell_WAIT will change to true
   return(false);
}  

int OnInit(){
   Alert("---------------------------------------------------------------------------------");
   Alert("therfore Lot size =",((Risk_Percent/100)*AccountBalance())/StopLoss);
   Alert("therfore cash max risk =, $",(Risk_Percent/100)*AccountBalance());
   Alert("Account Balance $",AccountBalance(),"  Risk % = ",(Risk_Percent/100));
   Alert("---------------------------------------------------------------------------------");
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason){
  }



void OnTick(){
//+------------------------------------------------------------------+
//| Indicator values                                                 |
//+------------------------------------------------------------------+
      //---getting value for iStdDev
   double std_D=iStdDev(NULL,0,St_Dev_period,0,MODE_SMA,PRICE_CLOSE,0);
      //--- getting values for EMA's
   double F_EMA   =iMA(Symbol(),0,Fast_EMA,0,MODE_EMA,PRICE_CLOSE,0);
   double M_EMA   =iMA(Symbol(),0,Medium_EMA,0,MODE_EMA,PRICE_CLOSE,0);
   double S_EMA   =iMA(Symbol(),0,Slow_EMA,0,MODE_EMA,PRICE_CLOSE,0);
   double Trend_EMA   =iMA(Symbol(),0,200,0,MODE_EMA,PRICE_CLOSE,0);
   
   if (run_count==0){
      Alert("---------------DID THIS RUN??",buy_WAIT,"-------------------------");
      if (start_condition(F_EMA,M_EMA,S_EMA)== true){buy_WAIT = true;};
      if (start_condition(F_EMA,M_EMA,S_EMA)== false){sell_WAIT = true;};
      run_count+=1;
      Alert("---------------",buy_WAIT,"-------------------------");
   }
   
   if (IsNewBar() == true){
   // new Bar... do i need to do a minus 1... ?   add start condition
   
//+------------------------------------------------------------------+
//| Close Position CONDITIONS                                        |
//+------------------------------------------------------------------+
   //--- check for Long close
   if((buy_WAIT==true)&&(F_EMA<M_EMA)){
      Alert("CLOSE LONG S_EMA=",S_EMA,"F_EMA=",F_EMA);
      OrderClose( LONG_ticket, lot_size, Bid, 2 );  //need to fix lot size to be original lot size
   }
   //--- check for Short close
   if((sell_WAIT==true)&&(F_EMA>M_EMA)){
      Alert("CLOSE SHORT ");
      OrderClose( SHORT_ticket, lot_size, Ask, 2 );
   }
   
//+------------------------------------------------------------------+
//| BUY OR SELL CONDITIONS                                           |
//+------------------------------------------------------------------+
   //--- check for buy
   if((F_EMA>M_EMA)&&(M_EMA>S_EMA)&&(buy_WAIT==false)){
      buy_WAIT=true;
      sell_WAIT=false;
      
      if(std_D>St_Dev_above){
      Alert("OPEN LONG risk $",((Risk_Percent/100)*AccountFreeMargin()),"std value = ",std_D);
      // Opening LONG
      LONG_ticket = OrderSend(Symbol(),OP_BUY,lot_size,Ask,2,Bid-StopLoss*Point,Bid+TakeProfit*Point,"No Brainer Open",0,0,clrGreen);
      }
   }
   //--- check for SELL
   if((F_EMA<M_EMA)&&(M_EMA<S_EMA)&&(sell_WAIT==false)){
      sell_WAIT=true;
      buy_WAIT=false;
      
      if(std_D>St_Dev_above){
      Alert("OPEN SHORT risk $",((Risk_Percent/100)*AccountBalance()),"std value = ",std_D);
      // Opening SHORT
      SHORT_ticket = OrderSend(Symbol(),OP_SELL,lot_size,Bid,2,Ask+StopLoss*Point,Ask-TakeProfit*Point,"No Brainer Open",0,0,clrRed);
      }
   }
   
   } //end new bar if
}
//+------------------------------------------------------------------+
