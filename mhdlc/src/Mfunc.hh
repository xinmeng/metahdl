#ifndef __MFUNC_HH__
#define __MFUNC_HH__

#include <stdio.h>
#include <assert.h>

#include <typeinfo>
#include <vector>
#include <list>
#include <map>
#include <set>
#include <string>
#include <iostream>
#include <utility>
#include <cmath>
#include <fstream>
#include <sstream>
#include <iomanip>
using namespace std;


typedef struct {
  string path;
  string name;
  string ext;
} tFileName;

typedef unsigned long long ulonglong;

typedef pair<ulonglong, ulonglong> BasedNum;


tFileName DecomposeName(const string &name);


extern int DebugPPLexer;
extern int DebugMHDLLexer;
extern int DebugMHDLParser;
extern int DebugSVLexer;
extern int DebugSVParser;

extern bool LEGACY_VERILOG_MODE;
extern bool FORCE_WIDTH_OUTPUT;
extern enum e_case_modify_style_t {PROPAGATE, MACRO, ELIMINATE}  CASE_MODIFY_STYLE;

extern vector<string> FILES;
extern list<string>   PATHS;
extern string WORKDIR;


void GetOpt(int, char**);
void RptOpt(ostream &o);
void CreateWorkdir();
char* SearchFile(const char *);
char* SearchFile(const string &);

inline ulonglong Max(const ulonglong &a, const ulonglong &b)
{
  return a > b ? a : b;
}

inline ulonglong Min(const ulonglong &a, const ulonglong &b)
{
  return a < b ? a : b;
}

inline ulonglong Power(const ulonglong &base, const ulonglong &exp)
{
  return (ulonglong) pow((float) base, (float) exp);
}

string regexp_substitute(const string&str, const string &pattern);

#endif
