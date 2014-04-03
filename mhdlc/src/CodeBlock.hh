#ifndef __CODEBLOCK_HH__
#define __CODEBLOCK_HH__

#include <algorithm>
#include "Expression.hh"
#include "Statement.hh"

extern bool OutputCodeLocation;

class CCodeBlock
{
protected:
  yy::location _loc;
  int _step;

#if 0
  set<CSymbol*> lsymbols, rsymbols;
#endif
  
public:
  inline CCodeBlock(const yy::location &loc) : _loc (loc), _step (2) {}
  inline CCodeBlock(const yy::location &loc, int step) : _loc (loc), _step (step) {}

  inline yy::location Loc() {return _loc;}
  inline void PrintLoc(ostream&os) { 
    if ( OutputCodeLocation ) {
      os << "// " << _loc << endl;
    }
  }
  virtual void Print(ostream&os=cout) =0;

  virtual void GetSymbol() =0;
  virtual inline void SetDriver() {
#if 0
    for (set<CSymbol*>::iterator iter = lsymbols.begin(); 
	 iter != lsymbols.end(); ++iter) {
      (*iter)->driver.push_back(this);
    }
#endif
  }

};


class CBlkAssign : public CCodeBlock
{
private: 
  CStmtSimple* _stmt;

public: 
  inline CBlkAssign(const yy::location &loc, CStmtSimple* stmt) : CCodeBlock(loc), _stmt (stmt) {}
  inline void Print(ostream&os=cout) {PrintLoc(os); os << "assign "; _stmt->Print(os);}

  inline void GetSymbol() { 
#if 0
    _stmt->GetSymbol(&lsymbols, &rsymbols); 
#endif
  }
};


class CBlkComb : public CCodeBlock 
{
private:
  CStatement* _stmt;
  
public:
  inline CBlkComb(const yy::location &loc, CStatement* stmt) : 
    CCodeBlock(loc), _stmt (stmt) {}

  inline CBlkComb(const yy::location &loc, int step, CStatement* stmt) : 
    CCodeBlock(loc, step), _stmt (stmt) {}

  inline void Print(ostream&os=cout) {
    PrintLoc(os); 
    if ( LEGACY_VERILOG_MODE ) {
      os << "always @(*) " << endl;
    }
    else {
      os << "always_comb" << endl; 
    }

    _stmt->Print(os, _step);
  }
  
  inline void GetSymbol() {
#if 0    
    _stmt->GetSymbol(&lsymbols, &rsymbols);
#endif
  }
    
  
};


class CFFItem
{
private:
  CExpression *_dst, *_src;
  CExpression* _rst_val;

public:
  inline CFFItem(CExpression* dst, CExpression* src) : _dst (dst), _src (src), _rst_val (NULL) {}
  inline CFFItem(CExpression* dst, CExpression* src, CExpression* rst_val) : _dst (dst), _src (src), _rst_val (rst_val) {}

public:
  inline void PrintRST(ostream&os, int indent) {
    if ( _rst_val ) {
      PUT_SPACE(indent);
      _dst->Print(os); 
      os << " <= ";
      _rst_val->Print(os);
      os << ";" << endl;
    }
  }

  inline void PrintFF(ostream&os, int indent) {
    PUT_SPACE(indent);
    _dst->Print(os); 
    os << " <= ";
    _src->Print(os);
    os << ";" << endl;
  }

  inline void GetSymbol(set<CSymbol*> *lsymb, set<CSymbol*> *rsymb) {
#if 0
    _dst->GetSymbol(lsymb);
    _src->GetSymbol(rsymb);
#endif
  }
};



class CBlkFF : public CCodeBlock
{
private:
  CSymbol *_clk, *_rst;
  vector<CFFItem*> *_ff_items;

public:
  inline CBlkFF(const yy::location &loc, CSymbol *clk, CSymbol *rst, vector<CFFItem*> *ff_items) : 
    CCodeBlock (loc), _clk (clk), _rst (rst), _ff_items (ff_items) {}

  inline CBlkFF(const yy::location &loc, CSymbol *clk, vector<CFFItem*> *ff_items) : 
    CCodeBlock (loc), _clk (clk), _rst (NULL), _ff_items (ff_items) {}

  inline CBlkFF(const yy::location &loc, int step, CSymbol *clk, CSymbol *rst, vector<CFFItem*> *ff_items) : 
    CCodeBlock (loc, step), _clk (clk), _rst (rst), _ff_items (ff_items) {}

  inline CBlkFF(const yy::location &loc, int step, CSymbol *clk, vector<CFFItem*> *ff_items) : 
    CCodeBlock (loc, step), _clk (clk), _rst (NULL), _ff_items (ff_items) {}
  
  inline void Print(ostream&os=cout) {
    PrintLoc(os);

    string always = LEGACY_VERILOG_MODE ? "always" : "always_ff";
      

    if ( _rst ) {
      os << always << " @(posedge " << _clk->name << " or negedge " << _rst->name << ")" << endl;
      PUT_SPACE(_step);
      os << "if (~" << _rst->name << ") begin" << endl;
      PrintRST(os, _step*2);
      PUT_SPACE(_step);
      os << "end" << endl;

      PUT_SPACE(_step);
      os << "else begin" << endl;
      PrintFF(os, _step*2);
      PUT_SPACE(_step);
      os << "end" << endl;
    }
    else {
      os << always << " @(posedge " << _clk->name << ") begin" << endl;
      PrintFF(os, _step*2);
      os << "end" << endl;
    }
  }

  inline void PrintRST(ostream&os, int indent) {
    for (vector<CFFItem*>::iterator iter = _ff_items->begin(); 
	 iter != _ff_items->end(); ++iter) {
      (*iter)->PrintRST(os, indent);
    }
  }

  inline void PrintFF(ostream&os, int indent) {
    for (vector<CFFItem*>::iterator iter = _ff_items->begin(); 
	 iter != _ff_items->end(); ++iter) {
      (*iter)->PrintFF(os, indent);
    }
  }

  inline void GetSymbol() {
#if 0
    rsymbols.insert(_clk); 
    if ( _rst ) rsymbols.insert(_rst);

    for (vector<CFFItem*>::iterator iter = _ff_items->begin(); 
	 iter != _ff_items->end(); ++iter) {
      (*iter)->GetSymbol(&lsymbols, &rsymbols);
    }
#endif
  }


};

class CBlkLegacyFF : public CCodeBlock
{
   private:
      CSymbol *_clk, *_rst;
      CStatement *_stmt;

   public: 
      inline CBlkLegacyFF(const yy::location &loc, CSymbol *clk, CSymbol *rst, CStatement *stmt) : 
	 CCodeBlock (loc), _clk (clk), _rst (rst), _stmt (stmt) {}

      inline CBlkLegacyFF(const yy::location &loc, CSymbol *clk, CStatement *stmt) : 
	 CCodeBlock (loc), _clk (clk), _rst (NULL), _stmt (stmt) {}

      inline CBlkLegacyFF(const yy::location &loc, int step, CSymbol *clk, CSymbol *rst, CStatement *stmt) : 
	 CCodeBlock (loc, step), _clk (clk), _rst (rst), _stmt (stmt) {}

      inline CBlkLegacyFF(const yy::location &loc, int step, CSymbol *clk, CStatement *stmt) : 
	 CCodeBlock (loc, step), _clk (clk), _rst (NULL), _stmt (stmt) {}

      inline void Print(ostream&os=cout) {
	 PrintLoc(os);

	 string always = LEGACY_VERILOG_MODE ? "always" : "always_ff";

	 os << always << " @(posedge " << _clk->name; 
	 if ( _rst ) {
	    os << " or negedge " << _rst->name;
	 }
	 os << ")" << endl;

	 _stmt->Print(os, _step);
      }

      inline void GetSymbol() {
#if 0
	 rsymbols.insert(_clk); 
	 if ( _rst ) rsymbols.insert(_rst);
	 
	 _stmt->GetSymbol(&lsymbols, &rsymbols);
#endif
      }
};


class CBlkInst : public CCodeBlock 
{
private:
  string _mod_name, _inst_name;
  vector<pair<string, CExpression*> > *_param;
  map<CSymbol*, CExpression*, CCompareConnection> *_connection;

public:
//   inline CBlkInst(yy::location &loc, 
// 		  const string &mod_name, 
// 		  const string &inst_name, 
// 		  map<string, CSymbol*> *connection ) : 
//     CCodeBlock (loc) , 
//     _mod_name (mod_name), _inst_name (inst_name), 
//     _connection (connection), _param (NULL) {}

  inline CBlkInst(yy::location &loc, 
		  const string &mod_name, 
		  vector<pair<string, CExpression*> > *param,
		  const string &inst_name, 
		  map<CSymbol*, CExpression*, CCompareConnection> *connection ) : 
    CCodeBlock (loc),
    _mod_name (mod_name), _inst_name (inst_name),
    _connection (connection), _param (param) {}

  inline void Print(ostream&os=cout) {
    PrintLoc(os);
    os << _mod_name << " ";
    if ( _param ) {
      os << "#(" << endl;
      PrintParam(os);
      PUT_SPACE(_mod_name.length() + 2);
      os << ") "  << _inst_name << " (" << endl;
      PrintConncetion(os);
      PUT_SPACE(_mod_name.length() + _inst_name.length() + 5);
      os << ");" << endl;
    }
    else {
      os << _inst_name << " (" << endl;
      PrintConncetion(os);
      PUT_SPACE(_mod_name.length() + _inst_name.length() + 2);
      os << ");" << endl;
    }
  }

  inline void PrintParam(ostream&os=cout) {
    for (vector<pair<string, CExpression*> >::iterator iter = _param->begin(); 
	 iter != _param->end(); ++iter) {
      PUT_SPACE(_mod_name.length() + 3);
//       iter->second->Print(os);
//       if ( ++iter != _param->end() ) {
// 	--iter;
// 	os << ",\t// " << iter->first << endl;
//       }
//       else {
// 	--iter;
// 	os << "\t// " << iter->first << endl;
//       }
      os << "." << iter->first << "( "; 
      iter->second->Print(os);
      os << " )";
      if ( ++iter != _param->end() ) {
	--iter;
	os << "," << endl;
      }
      else {
	--iter;
	os << "\t " << endl;
      }

    }
  }

  inline void PrintConncetion(ostream&os=cout) {
    for (map<CSymbol*, CExpression*, CCompareConnection>::iterator iter = _connection->begin(); 
	 iter != _connection->end(); ++iter) {
      PUT_SPACE(_mod_name.length() + _inst_name.length() + 6);
      if ( iter->second ) {
	os << "." << iter->first->name << " (";
	iter->second->Print(os);
	os << ")";
      }
      else {
	os << "." << iter->first->name << " ()";
      }
      if ( ++iter != _connection->end() ) {
	--iter;
	os << "," << endl;
      }
      else {
	--iter;
	os << endl;
      }
    }
  }

  inline void GetSymbol() {
#if 0
    for (map<CSymbol*, CExpression*, CCompareConnection>::iterator iter = _connection->begin(); 
	 iter != _connection->end(); ++iter) {
       if ( iter->second ) {
	  if ( iter->first->direction == INPUT ) {
	     iter->second->GetSymbol(&rsymbols);
	  }
	  else if ( iter->first->direction == OUTPUT ) {
	     iter->second->GetSymbol(&lsymbols);
	  }
	  else if ( iter->first->direction == INOUT ) {
	     iter->second->GetSymbol(&lsymbols);
	     iter->second->GetSymbol(&rsymbols);
	  }
	  else {
	     cerr << "**Internal ERROR:" << __FILE__ << ":" << __LINE__ 
		  << ":what direction should it be?? " << iter->first->name << endl;
	     exit(1);
	  }
       }
    }
#endif
  }

};


class CStateItem
{
private:
  string _name;
  yy::location _loc;
  CCaseItem* _stmt;
  
public:
  inline CStateItem(const yy::location &loc, const string &name, CCaseItem* stmt) : 
    _loc (loc), _name (name), _stmt (stmt) {}

  inline string Name() {return _name;}
  inline yy::location Loc() {return _loc;}
  inline void Print(ostream&os, int indent) {PrintLoc(os, indent);_stmt->Print(os, indent);}

  inline CCaseItem* CaseItem() { return _stmt;}

  inline void GetSymbol(set<CSymbol*> *lsymb, set<CSymbol*> *rsymb) {
#if 0
    _stmt->GetSymbol(lsymb, rsymb);
#endif
  }

private:
  inline void PrintLoc(ostream&os, int indent) {PUT_SPACE(indent), os << "// " << _loc << endl;}

};


class CStTransition
{
public:
  set<string> from, to;
};


#include "Table.hh"

class CBlkFSM : public CCodeBlock
{
private:
  string _name;
  bool _fsm_nc;
  CSymbol *_clk, *_rst;
  map<string, CStTransition*> *_graph;
  vector<CStateItem*> *_states;

  CBlkFF* _ff;
  CStmtBunch* _init;
  CBlkComb*  _body;

  
public:
  inline CBlkFSM(const yy::location &loc, 
		 const string &name, bool fsm_nc, CSymbol *clk, CSymbol *rst, 
		 map<string, CStTransition*>* graph,  CStmtBunch* init, vector<CStateItem*> *states) : 
    CCodeBlock(loc), 
    _name (name), _fsm_nc (fsm_nc), _clk (clk), _rst (rst), 
    _graph (graph), _states (states), 
    _ff (NULL), _init (init), _body (NULL) {}

  inline CBlkFSM(const yy::location &loc, int step,
		 const string &name, bool fsm_nc, CSymbol *clk, CSymbol *rst, 
		 map<string, CStTransition*>* graph, CStmtBunch* init, vector<CStateItem*> *states) : 
    CCodeBlock(loc, step), 
    _name (name), _fsm_nc (fsm_nc), _clk (clk), _rst (rst), 
    _graph (graph), _states (states), 
    _ff (NULL), _init (init), _body (NULL) {}


//   inline CBlkFSM(const yy::location &loc, 
// 		 const string &name, CSymbol *clk, CSymbol *rst, 
// 		 map<string, CStTransition*>* graph, vector<CStateItem*> *states) : 
//     CCodeBlock(loc), 
//     _name (name), _clk (clk), _rst (rst), 
//     _graph (graph), _states (states), 
//     _ff (NULL), _init (NULL), _body (NULL) {}

//   inline CBlkFSM(const yy::location &loc, int step,
// 		 const string &name, CSymbol *clk, CSymbol *rst, 
// 		 map<string, CStTransition*>* graph, vector<CStateItem*> *states) : 
//     CCodeBlock(loc, step), 
//     _name (name), _clk (clk), _rst (rst), 
//     _graph (graph), _states (states), 
//     _ff (NULL), _init (NULL), _body (NULL) {}



  inline void Print(ostream&os=cout) {
    os << "// Sequential part of FSM \"" << _name << "\" " << endl;
    if (_fsm_nc) {
        os << " // has been ommitted due to 'fsm_nc' keyword" << endl
           << endl;
    }
    else {
        _ff->Print(os);
        os << endl;
    }
    
    os << "// Combinational part of FSM \"" <<  _name << "\" " << endl;
    _body->Print(os);
    os << endl;
  }


  inline void CheckFSM() {
    bool has_err = false;
    string str = "FSM error:";
    for ( map<string, CStTransition*>::iterator iter = _graph->begin();
	  iter != _graph->end(); ++iter) {
      if ( iter->second->from.size() == 0 ) {
	has_err = true;
	str = str + "State \"" + iter->first + "\" is unreachable. ";
      }
      if ( iter->second->to.size() == 0 ) {
	has_err = true;
	str = str + "State \"" + iter->first + "\" is dead state. ";
      }
    }

    if ( has_err ) throw str;
  }

  inline void BuildFSM(CSymbolTab* SymbolTabel) {
    // always_comb part
    vector<CCaseItem*> *case_items = new vector<CCaseItem*>;
    ulonglong state_count = _states->size();
    CNumber *st_msb = new CNumber (state_count-1);

    CSymbol *state_reg = SymbolTabel->Exist( _name + "_cs" );
    state_reg->Update(st_msb);
    state_reg->io_fixed = true;
    state_reg = SymbolTabel->Exist( _name + "_ns");
    state_reg->Update(st_msb);
    state_reg->io_fixed = true;

    for ( int i=0; i<state_count; ++i){
      ostringstream tmp;

      CNumber *one_hot_val = new CNumber (state_count, 1<<i);
      tmp << state_count << "'b" << one_hot_val->BinStr(state_count);
      CBasedNum *one_hot_num = new CBasedNum (tmp.str(), 2);
      delete one_hot_val;

      CSymbol *state_name = SymbolTabel->Exist( (*_states)[i]->Name() );
      state_name->is_const = true;
      state_name->Update(LOGIC);
      state_name->msb      = st_msb;
      state_name->value = one_hot_num;

      CNumber *index_num = new CNumber (i);
      CSymbol *state_idx = SymbolTabel->Exist( "_" + (*_states)[i]->Name() + "_" );
      state_idx->is_const = true;
      state_idx->type     = INT;
      state_idx->value = index_num;

      case_items->push_back( (*_states)[i]->CaseItem() );
    }

    // default assignment
//     ostringstream sstr;
//     sstr << state_count << "'hX";
//     CBasedNum *xx_value = new CBasedNum(sstr.str(), 16);
//     CVariable *xx_net = new CVariable ( SymbolTabel->Exist( _name + "_ns" ) );
//     CStmtSimple *xx_stmt = new CStmtSimple ( xx_net, xx_value );
    CVariable *xx_value = new CVariable ( SymbolTabel->Exist( (*_states)[0]->Name() ));
    CVariable *xx_net = new CVariable ( SymbolTabel->Exist( _name + "_ns" ) );
    CStmtSimple *xx_stmt = new CStmtSimple ( xx_net, xx_value );




    CBasedNum *case_exp = new CBasedNum("1'b1", 2);
    CStmtCASE *fsm_case = new CStmtCASE(new CCaseType("unique", false), case_exp, case_items, xx_stmt);

    
    vector<CStatement*> *stmt_list = new vector<CStatement*>;
    if ( _init ) stmt_list->push_back(_init);
    stmt_list->push_back(fsm_case);

    CStmtBunch *comb_body = new CStmtBunch ( stmt_list );
    
    _body = new CBlkComb (_loc, comb_body);

    

    // FF part
    CVariable *cs = new CVariable ( SymbolTabel->Exist( _name + "_cs") );
    CVariable *ns = new CVariable ( SymbolTabel->Exist( _name + "_ns") );
    CVariable *init_state = new CVariable ( SymbolTabel->Exist( (*_states)[0]->Name() ) );

    CFFItem *ff_item = new CFFItem(cs, ns, init_state);
    vector<CFFItem*> *ff_items = new vector<CFFItem*>;
    ff_items->push_back(ff_item);

    _ff = new CBlkFF (_loc, _clk, _rst, ff_items);

  }

  inline void GetSymbol() {
#if 0
    _ff->GetSymbol();
    _body->GetSymbol();
#endif
  }

  inline void SetDriver() {
#if 0
    _ff->SetDriver();
    _body->SetDriver();
#endif
  }

};


class CBlkVerbtim : public CCodeBlock 
{
private:
  string _str;

public: 
  inline CBlkVerbtim(const yy::location &loc, const string &str) : 
    CCodeBlock(loc), _str (str) {}

  inline void Print(ostream&os=cout) {
    PrintLoc(os);
    os << _str << endl;
  }

  inline void GetSymbol() {}
};



#endif
