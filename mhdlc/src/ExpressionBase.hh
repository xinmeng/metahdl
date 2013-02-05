#ifndef __EXPRESSIONBASE_HH__
#define __EXPRESSIONBASE_HH__

#include "location.hh"

enum tDirection {INPUT, OUTPUT, INOUT, NONPORT};
enum tType {WIRE, REG, LOGIC, INT, INTEGER};

class CSymbol;


class CExpression
{
public: 
  inline CExpression() {};

public:
  virtual bool         IsConst()  = 0;
  virtual ulonglong    Width()  = 0;
  virtual double       DoubleValue() =0;
  virtual ulonglong    Value()  = 0;
  virtual CExpression* ValueExp() =0;
  virtual CExpression* Reduce()  =0;
  virtual void         Print(ostream& os=cout)  =0;
  virtual inline void  GetSymbol(set<CSymbol*> *) {}
  virtual bool         HasParam() =0;
  virtual bool         Update(tDirection direction) =0;
  virtual void         AddRoccure(yy::location loc) =0;
  virtual void         AddLoccure(yy::location loc) =0;
  virtual bool         Update(tType) =0;

};



#endif
