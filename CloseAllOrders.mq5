//+------------------------------------------------------------------+
//|                                                     CloseAll.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link "https://www.mql5.com"
#property version "1.00"
#property description "Close All Losing, All Orders ant All Profit with minimum money(default is 1 currency, like a 1$ or 1 euro)"
#property description "Closes orders in all pairs like a BTCUSD, XAUUSD etc"
#property script_show_inputs

#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>

//---
CPositionInfo m_position;
CTrade sTrade;
//--- input parameters
input double InpProfit = 1; // Minimum profit

#define async sTrade.SetAsyncMode(true);
#define BtnCloseALL "Close All"
#define BtnCloseProfit "Close Profit"
#define BtnCloseLosing "Close Losing"

int OnInit()
{
  CreateButton(BtnCloseALL, "Close All", clrDarkGray, 110, 30);
  CreateButton(BtnCloseProfit, "Close Profit", C'0, 102, 204', 110, 60);
  CreateButton(BtnCloseLosing, "Close Losing", C'255, 102, 102', 110, 90);
  ChartRedraw();
  return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
    ObjectDelete(0, BtnCloseALL); 
    ObjectDelete(0, BtnCloseLosing);
    ObjectDelete(0, BtnCloseProfit);
}
void OnTick()
{
}
//+------------------------------------------------------------------+
void OnChartEvent(
    const int id,         // event ID
    const long &lparam,   // long type event parameter
    const double &dparam, // double type event parameter
    const string &sparam  // string type event parameter
)
{
  if (id == CHARTEVENT_OBJECT_CLICK)
  {
    HandleButtonClick(sparam);
  }
}

void HandleButtonClick(const string &buttonName)
{
  if (buttonName == BtnCloseLosing)
  {
    CloseAllLosing();
  }
  else if (buttonName == BtnCloseProfit)
  {
    CloseAllProfit();
  }
  else if (buttonName == BtnCloseALL)
  {
    CloseAllOrders();
  }
  ChartRedraw();
  ObjectSetInteger(0, buttonName, OBJPROP_COLOR, clrBlack);
  Sleep(100);
  ObjectSetInteger(0, buttonName, OBJPROP_STATE, false);
  ObjectSetInteger(0, buttonName, OBJPROP_COLOR, clrWhite);
  ChartRedraw();
}

void CloseAllLosing()
{
  ulong st = GetMicrosecondCount();
  int totalPositions = PositionsTotal();

  async
  for (int cnt = totalPositions - 1; cnt >= 0 && !IsStopped(); cnt--)
  {
    if (PositionSelectByTicket(PositionGetTicket(cnt)))
    {
      if (PositionGetDouble(POSITION_PROFIT) < 0) // losing money
      {
        sTrade.PositionClose(PositionGetInteger(POSITION_TICKET), 100);
        uint code = sTrade.ResultRetcode();
        Print(IntegerToString(code));
      }
    }
  }

  for (int i = 0; i < totalPositions; i++)
  {
    Print(IntegerToString(GetMicrosecondCount() - st) + "micro " + IntegerToString(PositionsTotal()));
    if (PositionsTotal() <= 0)
    {
      break;
    }
    Sleep(100);
  }
}


void CloseAllProfit()
{
  async

      for (int i = PositionsTotal() - 1; i >= 0; i--) if (m_position.SelectByIndex(i))
  {
    double profit = m_position.Commission() + m_position.Swap() + m_position.Profit();
    if (profit > InpProfit) // profit money
      sTrade.PositionClose(m_position.Ticket());
  }
}

void CloseAllOrders()
{
  ulong st = GetMicrosecondCount();

  async

      for (int cnt = PositionsTotal() - 1; cnt >= 0 && !IsStopped(); cnt--)
  {
    if (PositionGetTicket(cnt))
    {
      sTrade.PositionClose(PositionGetInteger(POSITION_TICKET), 100);
      uint code = sTrade.ResultRetcode();
      Print(IntegerToString(code));
    }
  }

  for (int i = 0; i < 100; i++)
  {
    Print(IntegerToString(GetMicrosecondCount() - st) + "micro " + IntegerToString(PositionsTotal()));
    if (PositionsTotal() <= 0)
    {
      break;
    }
    Sleep(100);
  }
}

bool CreateButton(
    string objName,
    const string text,
    const color back_clr,
    int x,
    int y,
    const long chart_ID = 0,
    const int sub_window = 0,
    const int width = 100,
    const int height = 22,
    const ENUM_BASE_CORNER corner = CORNER_RIGHT_LOWER,
    const string font = "Arial",
    const int font_size = 10,
    const color clr = clrWhiteSmoke,
    const color border_clr = clrNONE,
    const bool back = false,
    const bool state = false,
    const bool selection = false,
    const bool hidden = false,
    const long z_order = 0)
{
  ResetLastError();
  if (!ObjectCreate(chart_ID, objName, OBJ_BUTTON, sub_window, 0, 0))
  {
    Print(__FUNCTION__,
          ": failed to create the button! Error code = ", GetLastError());
    return (false);
  }
  ObjectSetInteger(chart_ID, objName, OBJPROP_XDISTANCE, x);
  ObjectSetInteger(chart_ID, objName, OBJPROP_YDISTANCE, y);
  ObjectSetInteger(chart_ID, objName, OBJPROP_XSIZE, width);
  ObjectSetInteger(chart_ID, objName, OBJPROP_YSIZE, height);
  ObjectSetInteger(chart_ID, objName, OBJPROP_CORNER, corner);
  ObjectSetString(chart_ID, objName, OBJPROP_TEXT, text);
  ObjectSetString(chart_ID, objName, OBJPROP_FONT, font);
  ObjectSetInteger(chart_ID, objName, OBJPROP_FONTSIZE, font_size);
  ObjectSetInteger(chart_ID, objName, OBJPROP_COLOR, clr);
  ObjectSetInteger(chart_ID, objName, OBJPROP_BGCOLOR, back_clr);
  ObjectSetInteger(chart_ID, objName, OBJPROP_BORDER_COLOR, border_clr);
  ObjectSetInteger(chart_ID, objName, OBJPROP_BACK, back);
  ObjectSetInteger(chart_ID, objName, OBJPROP_STATE, state);
  ObjectSetInteger(chart_ID, objName, OBJPROP_SELECTABLE, selection);
  ObjectSetInteger(chart_ID, objName, OBJPROP_SELECTED, selection);
  ObjectSetInteger(chart_ID, objName, OBJPROP_HIDDEN, hidden);
  ObjectSetInteger(chart_ID, objName, OBJPROP_ZORDER, z_order);
  return (true);
}
