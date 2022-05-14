#ifndef __MFUNC_HH__
#define __MFUNC_HH__

#include <stdio.h>
#include <assert.h>
#include <unistd.h>

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
#include <regex>
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
extern list<string>   PATHS, M_DIRS, I_DIRS;
extern string M_BASE, V_BASE;
extern set<string> I_BASE;
extern map<string, string> MIRROR;

extern regex regex_empty_net;
extern regex regex_bin_num; 
extern regex regex_dec_num;
extern regex regex_hex_num;
extern regex regex_int_num;

//extern string WORKDIR;


void GetOpt(int, char**);
void RptOpt();
void CreateWorkdir();
// char* SearchFile(const char *);
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
int    regexp_match(const string &str, const string &pattern);

string ItoS(ulonglong num, int width=-1, int base=2);
ulonglong StoI(const string &str, int base=10);

ulonglong wx_ecc_width(const ulonglong num);
ulonglong log2_cnt(const ulonglong num);


#endif
