#ifndef __GENCODESTMT_HH__
#define __GENCODESTMT_HH__

#include "CodeBlock.hh"

extern bool OutputCodeLocation;

class CGenCodeStmt
{
protected:
    yy::location _loc;
    int _step;

public:
    inline CGenCodeStmt(const yy::location &loc): _loc (loc), _step (2) {}
    inline CGenCodeStmt(const yy::location &loc, int step): _loc (loc), _step (step) {}

    inline yy::location Loc() {return _loc;}
    inline void PrintLoc(ostream &os) {
        if (OutputCodeLocation) {
            os << "// " << _loc << endl;
        }
    }

    virtual void Print(ostream &os=cout) =0;
};

class CGenCodeStmtAssign : public CGenCodeStmt
{
    
}




#endif

