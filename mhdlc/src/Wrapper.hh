#ifndef __WRAPPER_HH__
#define __WRAPPER_HH__

#include "location.hh"
#include "position.hh"

#include <libgen.h>

#include <map>
#include <vector>
#include <string>

using namespace std;

#include "vpp.hh"
#include "Table.hh"
#include "Mfunc.hh"

extern bool PreservePostPPFile;

class CWarningLocMessage
{
private:
  yy::location loc;
  string msg;

public:
  inline CWarningLocMessage (const yy::location &loc_, const string &msg_)  : 
    loc (loc_), msg (msg_) {};

  inline ostream& Print(ostream &os=cerr) {
    os << "\033[00;35m\n**WARNING:" << loc << ":" << msg << "\033[00m" << endl;
    return os;
  }
};

// ------------------------------
//   Wrapper base class
// ------------------------------
class CWrapper 
{
public:
  string filename;
  string path, workdir;
  string module_name;
  string extension;
  string post_pp_file;
  string gen_file;
  yy::location module_location;

  bool is_global_param;


  CIOTab* io_table;
  CParamTab* param_table;
  CSymbolTab *symbol_table;

private:
  string _my_name;

protected:
  vector<CWarningLocMessage*> _warning_msg;
  vector<string> _lint_warning_msg;
  set<string> _lint_warning_flag;


public:
  inline CWrapper() {};
  inline CWrapper(string f, string n) : is_global_param (false), filename (f), _my_name (n) {
    DecomposeName();
    SetPostPPFile();
    
    gen_file = module_name;

    io_table = new CIOTab;
    param_table = new CParamTab;
    symbol_table = new CSymbolTab;
  }

  inline void RunPP() const 
  {
    FILE *in, *out;

    in  = fopen(filename.c_str(), "r");
    out = fopen(post_pp_file.c_str(), "w");

    if ( in && out ) {
      int i = preprocess(in, filename, out);
      fclose(in);
      fclose(out);
      if ( i ) {
	cerr << "**Preprocessor Error: Preprocessor syntax error on file: " << filename << endl;
	exit(1);
      }
    }
    else {
      cerr << "**Preprocessor Error: ";
      if ( !in ) {
	cerr << filename << " cannot be opened for read. ";
      }
      if ( !out ) {
	cerr << post_pp_file << " cannot be opened for write.";
      }
      cerr << endl;
      exit(1);
    }
  }


  inline void DecomposeName() 
  {
    size_t pos ;
    string base_filename;

    char *str = (char *)calloc(1, strlen(filename.c_str())+1);
    strcpy(str, filename.c_str());
    path = dirname(str);

    strcpy(str, filename.c_str());
    base_filename = basename(str);

    pos = base_filename.find_last_of(".");
    if ( pos == string::npos ) {
        module_name  = base_filename;
        extension   = "";
    }
    else {
      module_name  = base_filename.substr(0, pos);
      extension    = base_filename.substr(pos);
    }
    
    if (MIRROR.count(path) > 0) 
        workdir = MIRROR[path];
    else 
        workdir = V_BASE;
  }

  inline void SetPostPPFile() 
  {
    post_pp_file = workdir + "/" + module_name + extension + ".postpp";
  }

  virtual inline void RemovePostPPFile() {
    if ( !PreservePostPPFile ) 
      if ( unlink(post_pp_file.c_str()) ) {
	cerr << "Cannot unlink " << post_pp_file << endl;
      }
  }

  virtual inline string GetGenFileName() 
  {
    if ( extension == ".mhdl" ) 
      return workdir + "/" + gen_file + ".sv";
    else 
      return workdir + "/" + gen_file + extension;
  }

  inline void error(const int lineno, const string &msg) const {
    cerr << "\033[00;31m\n**" << _my_name << " Lexer ERROR:" << filename << ":" << lineno << ":" << msg << "\033[00m" << endl;
    exit(1);
  }

  inline  void error(const yy::position &pos, const string &msg) const {
    cerr << "\033[00;31m\n**" << _my_name << " Lexer ERROR:" << pos << ":" << msg << "\033[00m" << endl;
    exit(1);
  }

  inline void error(const yy::location &loc, const string &msg) const {
    cerr << "\033[00;31m\n**" << _my_name << " Parser ERROR:" << loc << ":" << msg << "\033[00m" << endl;
    exit(1);
  }
  
  virtual inline void warning(const yy::location &loc, const string &msg)  {
    CWarningLocMessage *warningmsg = new CWarningLocMessage(loc, msg);
    _warning_msg.push_back(warningmsg);
    // cerr << "\033[00;35m\n**" << _my_name << " Parser WARNING:" << loc << ":" << msg << "\033[00m" << endl;
  }
};


class CCtrlValType
{
public:
  string str;
  bool   flag;
  ulonglong num;

public:
  inline CCtrlValType() : str (""), flag (false), num (0) {}

};



// ------------------------------
//   Extern G_ModuleTable
// ------------------------------
extern CModTab G_ModuleTable;


// ------------------------------
//   MHDL Wrapper
// ------------------------------
class CMHDLwrapper : public CWrapper
{
public:
  bool in_fsm, fsm_nc;
  bool in_sequential;
  string fsm_name, fsm_clk_name, fsm_rst_name;
  CSymbol *fsm_clk, *fsm_rst;
  string state_name;
  map<string, CStTransition*> *state_graph;
  vector<CCodeBlock*> *code_blocks;
  CModule *mod_template;
  string mod_template_name;
  map<string, CCtrlValType*> mctrl;
  set<string> symbol_to_remove;


private:
  inline CMHDLwrapper() {};
  
public:
  inline CMHDLwrapper(string f) : CWrapper(f, "MHDL") 
  {
    in_fsm = false;
    fsm_nc = false;
    in_sequential = false;

    state_graph  = NULL;
    code_blocks  = new vector<CCodeBlock*>;
    mod_template = NULL;

    mctrl["modname"] = new CCtrlValType; // str
    mctrl["modname"]->str = module_name;

    mctrl["portchk"] = new CCtrlValType; // flag

    mctrl["outfile"] = new CCtrlValType; // str
    mctrl["outfile"]->str = gen_file;

    mctrl["hierachydepth"] = new CCtrlValType; // num
    mctrl["hierachydepth"]->num = 300;
    
    mctrl["clock"] = new CCtrlValType; // str
    mctrl["clock"]->str = "clk";

    mctrl["reset"] = new CCtrlValType; // str
    mctrl["reset"]->str = "rst_n";

    mctrl["multidriverchk"] = new CCtrlValType; // flag
    mctrl["multidriverchk"]->flag = true;

    mctrl["relaxedfsm"] = new CCtrlValType; // flag
    mctrl["relaxedfsm"]->flag = true;

    mctrl["exitonwarning"] = new CCtrlValType; // flag
    mctrl["exitonlintwarning"] = new CCtrlValType; // flag

    mctrl["exitonportchk"] = new CCtrlValType; // flag
    mctrl["exitonportchk"]->flag = true;

    mctrl["exitonmultidriver"] = new CCtrlValType; // flag

  }

//   inline void warning(const yy::location &loc, const string &msg)  {
//     CWrapper::warning(loc, msg);

//     if ( mctrl["exitonwarning"]->flag ) {
//        cerr << "\033[00;31mExit-On-Warning set for module " << mctrl["modname"]->str << ", fix warning or remove this option to continue." << "\033[00m" << endl;
//       exit(1);
//     }
//   }

  inline void LintWarning(const string &msg, const string &exit_switch="exitonlintwarning")  {
    _lint_warning_msg.push_back(msg);
    _lint_warning_flag.insert(exit_switch);
    
//     cerr << "\033[00;35m**Lint Warning on Module \"" + mctrl["modname"]->str + "\":" + msg << "\033[00m" << endl;

//     if ( mctrl[exit_switch]->flag ) {
//       cerr << "\033[00;31m\"" << exit_switch << "\" set for module " << mctrl["modname"]->str << ", fix warning or remove this option to continue." << "\033[00m" << endl;
//       exit(1);
//     }
  }


  // MHDL specific interface
  void OpenIO() ;
  void CloseIO() ;
  void Parse();


  void SwitchLexerSrc();
  void RestoreLexerSrc();
  int  HierDepth();
  void DepParse();

  inline string GetGenFileName() {
    if ( LEGACY_VERILOG_MODE ) {
      return workdir + "/" + mctrl["outfile"]->str + ".v";
    }
    else {
      return workdir + "/" + mctrl["outfile"]->str + ".sv";
    }
  }

  inline void GenSV() {
    CModule *mod = G_ModuleTable.Exist(mctrl["modname"]->str);
    if ( mod ) {
      cerr << "Module " << mctrl["modname"]->str << " already exists in module database (" << mod->loc << "), drop MHDL parse result." << endl;
      delete io_table;
      delete param_table;
      delete code_blocks;
      delete symbol_table;
    }
    else {
      // port checking
      string msg = symbol_table->ExtractIO(io_table);
      if ( mctrl["portchk"]->flag ) {
	msg  += io_table->ChkMissingPort();
	if ( msg != "" ) {
	  LintWarning("Port checking:\n" + msg + "\n", "exitonportchk");
	}
      }


#if 0
      // multi-driver checking
      if ( mctrl["multidriverchk"]->flag ) {
	msg = "";
	msg = symbol_table->ChkMultiDriver();
	if ( msg != "" ) {
	  LintWarning("Multiple Driver Report:\n" + msg, "exitonmultidriver");
	}
      }
#endif

      mod = new CModMHDL (module_location, mctrl["modname"]->str, 
			  io_table, param_table, code_blocks, symbol_table);
      G_ModuleTable.Insert(mod);

      ofstream outfile;
      outfile.open(GetGenFileName().c_str());
      if ( outfile.is_open() ) {
	mod->Print(outfile);
	outfile.close();

	cerr << "Module \"" << mctrl["modname"]->str << "\" is created in " << GetGenFileName() << endl;
      }
      else {
	cerr << "**MWrapper Error: Cannot open file " << GetGenFileName() << endl;
	exit(1);
      }

      for (vector<CWarningLocMessage*>::iterator iter = _warning_msg.begin();
	   iter != _warning_msg.end(); iter++) {
	(*iter)->Print(cerr);
      }
      if ( mctrl["exitonwarning"]->flag ) {
	exit(1);
      }
      
      if (_lint_warning_msg.size()) {
	cerr << endl
	     << "\033[00;35m**Lint Warning on Module \"" 
	     << mctrl["modname"]->str << "\":" 
	     << "\033[00m" 
	     << endl;	
      }
      for (vector<string>::iterator iter = _lint_warning_msg.begin();
	   iter != _lint_warning_msg.end(); iter++) {
	cerr << "\033[00;35m"
	     << (*iter) 
	     << "\033[00m" 
	     << endl;	
      }
      if (mctrl["exitonlintwarning"]->flag && _lint_warning_msg.size() > 0) {
	cerr << "\033[00;31m\"exitonlintwarning\" set for module " 
	     << mctrl["modname"]->str 
	     << ", fix warning or remove this option to continue." 
	     << "\033[00m" << endl;
	exit(1);
      }
      else if (mctrl["exitonportchk"]->flag && _lint_warning_flag.count("exitonportchk") > 0) {
	cerr << "\033[00;31m\"exitonportchk\" set for module " 
	     << mctrl["modname"]->str 
	     << ", fix warning or remove this option to continue." 
	     << "\033[00m" << endl;
	exit(1);
      }
      else if (mctrl["exitonmultidriver"]->flag && _lint_warning_flag.count("exitonmultidriver") > 0) {
	cerr << "\033[00;31m\"exitonmultidriver\" set for module " 
	     << mctrl["modname"]->str 
	     << ", fix warning or remove this option to continue." 
	     << "\033[00m" << endl;
	exit(1);
      }
    }
  }

  inline bool SetCtrl(const string &name, bool flag) {
    if ( mctrl.count(name) > 0 ) {
      mctrl[name]->flag = flag;
      return true;
    }
    else {
      return false;
    }
  }

  inline bool SetCtrl(const string &name, const string &str) {
    if ( mctrl.count(name) > 0 ) {
      mctrl[name]->str = str;
      return true;
    }
    else {
      return false;
    }
  }

  inline bool SetCtrl(const string &name, ulonglong num) {
    if ( mctrl.count(name) > 0 ) {
      mctrl[name]->num = num;
      return true;
    }
    else {
      return false;
    }
  }



};

class CSVwrapper : public CWrapper
{
private: 
  inline CSVwrapper() {}
  
public:
  inline CSVwrapper(string f) : CWrapper(f, "SV") {
    // these 3 pointers will construted in svparser.y
    delete io_table;
    delete param_table;
    delete symbol_table;
  };


  void OpenIO() ;
  void CloseIO() ;
  void Parse();

  inline  void BuildModule() 
  {
    CModule *mod = G_ModuleTable.Exist(module_name);
    if ( mod ) {
      cerr << "Module " << module_name << " already exists in module database (" << mod->loc << "), drop SV parse result." << endl;
      delete io_table;
      delete param_table;
      delete symbol_table;
    }
    else {
      mod = new CModSV (module_location, module_name, io_table, param_table);
      G_ModuleTable.Insert(mod);
    }
  }
};



#endif
