#include "svparser.bison.hh"
#include "MetaHDL.hh"


void
CSVwrapper::Parse()
{
  RunPP();

  yy::svParser svparser (*this);

  OpenIO();
  svparser.set_debug_level(DebugSVParser);
  svparser.parse();
  CloseIO();

}

