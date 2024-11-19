//+------------------------------------------------------------------+
//|                                                      CoreBox.mq4 |
//|                                         Copyright 2024, Conisma. |
//|                                     https://www.blog.conisma.com |
//+------------------------------------------------------------------+
#property strict
#property indicator_chart_window
extern int ATRPeriod = 55;
extern string SupportedTimeFrame   = "D1 - H4 - H1 - M15";
extern ENUM_TIMEFRAMES    CustomTF          = PERIOD_D1;
extern int    UnitToProcess     = 20;
extern int    DojiDiff          = 2;
extern color  UpColor           = C'218,250,218';
extern color  DownColor         = C'250,211,211';
extern color  DojiColor         = C'255,245,195';


datetime starttime[],endtime[];
double lowprice[],highprice[],closeprice[];
double atr[];
int bars_in_one_rectangle;
color BarsColor[];
int ChartPeriod;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//----
   ChartPeriod=Period();

//D1
   if(CustomTF==PERIOD_D1)
     {
      switch(ChartPeriod)
        {
         case PERIOD_M1 :
            bars_in_one_rectangle=1440-1;
            break;
         case PERIOD_M5 :
            bars_in_one_rectangle=288-1;
            break;
         case PERIOD_M15:
            bars_in_one_rectangle=96-1;
            break;
         case PERIOD_M30:
            bars_in_one_rectangle=48-1;
            break;
         case PERIOD_H1 :
            bars_in_one_rectangle=24-1;
            break;
         case PERIOD_H4 :
            bars_in_one_rectangle=6-1;
            break;
         default        :
            ChartPeriod=240;
        }
     }
//H4
   else
      if(CustomTF==PERIOD_H4)
        {
         switch(ChartPeriod)
           {
            case PERIOD_M1 :
               bars_in_one_rectangle=240-1;
               break;
            case PERIOD_M5 :
               bars_in_one_rectangle=48-1;
               break;
            case PERIOD_M15:
               bars_in_one_rectangle=16-1;
               break;
            case PERIOD_M30:
               bars_in_one_rectangle=8-1;
               break;
            case PERIOD_H1 :
               bars_in_one_rectangle=4-1;
               break;
            default        :
               ChartPeriod=60;
           }
        }
      //H1
      else
         if(CustomTF==PERIOD_H1)
           {
            switch(ChartPeriod)
              {
               case PERIOD_M1 :
                  bars_in_one_rectangle=60-1;
                  break;
               case PERIOD_M5 :
                  bars_in_one_rectangle=12-1;
                  break;
               case PERIOD_M15:
                  bars_in_one_rectangle=4-1;
                  break;
               case PERIOD_M30:
                  bars_in_one_rectangle=2-1;
                  break;
               default        :
                  ChartPeriod=30;
              }
           }
         //M30
         else
            if(CustomTF==PERIOD_M30)
              {
               switch(ChartPeriod)
                 {
                  case PERIOD_M1 :
                     bars_in_one_rectangle=30-1;
                     break;
                  case PERIOD_M5 :
                     bars_in_one_rectangle=6-1;
                     break;
                  case PERIOD_M15:
                     bars_in_one_rectangle=2-1;
                     break;
                  default        :
                     ChartPeriod=15;
                 }
              }
            //M15
            else
               if(CustomTF==PERIOD_M15)
                 {
                  switch(ChartPeriod)
                    {
                     case PERIOD_M1 :
                        bars_in_one_rectangle=15-1;
                        break;
                     case PERIOD_M5 :
                        bars_in_one_rectangle=3-1;
                        break;
                     default        :
                        ChartPeriod=5;
                    }
                 }
               //M5
               else
                  if(CustomTF==PERIOD_M5)
                    {
                     switch(ChartPeriod)
                       {
                        case PERIOD_M1 :
                           bars_in_one_rectangle=5-1;
                           break;
                        default        :
                           ChartPeriod=1;
                       }
                    }



   ArrayResize(starttime, UnitToProcess);
   ArrayResize(endtime, UnitToProcess);
   ArrayResize(lowprice, UnitToProcess);
   ArrayResize(closeprice, UnitToProcess);
   ArrayResize(highprice, UnitToProcess);
   ArrayResize(BarsColor, UnitToProcess);
   ArrayResize(atr, UnitToProcess);



//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   for(int w=0; w<UnitToProcess; w++)
     {
      ObjectDelete("CustomTF"+w);
     }
   Comment("");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {

   for(int w=0; w<UnitToProcess; w++)
     {
      ObjectDelete("CustomTF"+w);
     }
   for(int w=0; w<UnitToProcess; w++)
     {
      switch(CustomTF)
        {
         case PERIOD_MN1 :
            atr[w] = iATR(NULL,PERIOD_D1,ATRPeriod,w);
            break;
         case PERIOD_W1:
            atr[w] = iATR(NULL,PERIOD_H4,ATRPeriod,w);
            break;
         case PERIOD_D1 :
            atr[w] = iATR(NULL,PERIOD_H1,ATRPeriod,w);
            break;
         case PERIOD_H4 :
            atr[w] = iATR(NULL,PERIOD_M15,ATRPeriod,w);
            break;
         case PERIOD_H1:
            atr[w] = iATR(NULL,PERIOD_M5,ATRPeriod,w);
            break;
         case PERIOD_M15:
            atr[w] = iATR(NULL,PERIOD_M1,ATRPeriod,w);
            break;
         default        :
            atr[w] = iATR(NULL,PERIOD_M1,ATRPeriod,w);
        }
     }
   for(int w=0; w<UnitToProcess-1; w++)
     {
      starttime[w]=iTime(NULL,CustomTF,w);
      endtime[w]=starttime[w]+bars_in_one_rectangle*Period()*60;
      lowprice[w]=iLow(NULL,CustomTF,w);
      highprice[w]=iHigh(NULL,CustomTF,w);
      closeprice[w]=iClose(NULL,CustomTF,w);


      if(iOpen(NULL,CustomTF,w+1)<iClose(NULL,CustomTF,w+1)-(DojiDiff*Point))
        {
         BarsColor[w]=UpColor;
         ObjectCreate("CustomTF"+w,OBJ_RECTANGLE,0,starttime[w],closeprice[w+1],endtime[w],closeprice[w+1]-atr[w+1]);
         ObjectSet("CustomTF"+w,OBJPROP_COLOR,BarsColor[w]);
        }
      else
        {
         if(iOpen(NULL,CustomTF,w+1)>iClose(NULL,CustomTF,w+1)+(DojiDiff*Point))
           {
            BarsColor[w]=DownColor;
            ObjectCreate("CustomTF"+w,OBJ_RECTANGLE,0,starttime[w],closeprice[w+1],endtime[w],closeprice[w+1]+atr[w+1]);
            ObjectSet("CustomTF"+w,OBJPROP_COLOR,BarsColor[w]);
           }
         else
           {
            BarsColor[w]=DojiColor;
            ObjectCreate("CustomTF"+w,OBJ_RECTANGLE,0,starttime[w],closeprice[w+1]+(atr[w+1]/2),endtime[w],closeprice[w+1]+(atr[w+1]/2));
            ObjectSet("CustomTF"+w,OBJPROP_COLOR,BarsColor[w]);
           }
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
