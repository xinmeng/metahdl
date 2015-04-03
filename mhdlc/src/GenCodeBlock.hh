#ifndef __GENCODEBLOCK_HH__
#define __GENCODEBLOCK_HH__

#include "CodeBlock.hh"

extern bool OutputCodeLocation;

class CGenCodeBlock
{
protected:
    yy::location _loc;
    int _step;

public:
    inline CGenCodeBlock(const yy::location &loc): _loc (loc), _step (2) {}
    inline CGenCodeBlock(const yy::location &loc, int step): _loc (loc), _step (step) {}

    inline yy::location Loc() {return _loc;}
    inline void PrintLoc(ostream &os) {
        if (OutputCodeLocation) {
            os << "// " << _loc << endl;
        }
    }

    virtual void Print(ostream &os=cout) =0;
};

class CGenCodeBlk




#endif

