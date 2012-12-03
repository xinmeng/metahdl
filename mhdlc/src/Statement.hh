#ifndef __STATEMENT_HH__
#define __STATEMENT_HH__

#include "Expression.hh"

#define PUT_SPACE(indent) for (int i=0; i<indent; ++i) os << " "

class CStatement
{
public:
  yy::location loc;
  int step;

  inline CStatement() : step (2) {}
  inline CStatement(int step_) : step (step_) {}
  
public:
  inline virtual void Evaluate() {
    ostringstream sstr;
    sstr << "Internal Error: Try to evaluate statement at " << loc << endl;
    throw sstr.str();
  }

  virtual void Print(ostream& os, int indent) =0;
  virtual void GetSymbol(set<CSymbol*> *lsymb, set<CSymbol*> *rsymb) =0;
};


class CStmtSimple : public CStatement
{
private:
  CExpression *_lval, *_rval;
  string _assignment;

public:
  inline CStmtSimple() : 
    CStatement(), _lval (NULL), _rval (NULL), _assignment ("") {}

  inline CStmtSimple(int step_) : 
    CStatement(step_), _lval (NULL), _rval (NULL), _assignment ("") {}

  inline CStmtSimple(CExpression *lval, CExpression *rval) : 
    CStatement(), _lval (lval), _rval (rval), _assignment (" = ") {}

  inline CStmtSimple(CExpression *lval, CExpression *rval, int step_) : 
    CStatement(step_), _lval (lval), _rval (rval), _assignment (" = ") {}
 
  inline CStmtSimple(CExpression *lval, CExpression *rval, bool nonblk) : 
    CStatement(), _lval (lval), _rval (rval), _assignment (" <= ") {}

  inline CStmtSimple(CExpression *lval, CExpression *rval, int step_, bool nonblk) : 
    CStatement(step_), _lval (lval), _rval (rval), _assignment (" <= ") {}


public:
  inline virtual void Evaluate() {
    if (typeid (*_lval) != typeid (CArithMacro)) {
      ostringstream sstr;
      sstr << "Internal Evaluate: " << loc 
	   << ", assignment state can only be evaluated on a arithmetic macro lval." << endl;
      throw sstr.str();
    }
    else {
      CArithMacro *var = dynamic_cast<CArithMacro*> (_lval);
      var->SetValue(_rval);
    }
  }

  inline void Print(ostream&os=cout, int indent=0) {
    PUT_SPACE(indent);
    if ( _lval ) {
      _lval->Print(os); 
      os << _assignment; 
      _rval->Print(os);
    }
    os << ";" << endl;
  }

  inline void GetSymbol(set<CSymbol*> *lsymb, set<CSymbol*> *rsymb) {
#if 0
    if ( _lval ) {
      _lval->GetSymbol(lsymb);
      _rval->GetSymbol(rsymb);
    }
#endif    
  }
};



class CStmtFOR : public CStatement
{
private:
  CExpression *_fmr_lexp, *_fmr_rexp;
  CExpression *_mid_exp;
  CExpression *_lst_lexp, *_lst_rexp;
  CStatement *_stmt;

private:
  inline CStmtFOR() : CStatement() {}

public:
  inline CStmtFOR(CExpression *fmr_lexp, CExpression* fmr_rexp, 
		  CExpression *mid_exp, 
		  CExpression *lst_lexp, CExpression* lst_rexp,
		  CStatement *stmt) : 
    CStatement(), 
    _fmr_lexp (fmr_lexp), _fmr_rexp (fmr_rexp),
    _mid_exp (mid_exp),
    _lst_lexp (lst_lexp), _lst_rexp (lst_rexp),
    _stmt (stmt) {}

  inline CStmtFOR(CExpression *fmr_lexp, CExpression* fmr_rexp, 
		  CExpression *mid_exp, 
		  CExpression *lst_lexp, CExpression* lst_rexp, 
		  CStatement *stmt, int step_) : 
    CStatement(step_), 
    _fmr_lexp (fmr_lexp), _fmr_rexp (fmr_rexp),
    _mid_exp (mid_exp),
    _lst_lexp (lst_lexp), _lst_rexp (lst_rexp),
    _stmt (stmt) {}

public:
  inline void GetSymbol(set<CSymbol*> *lsymb, set<CSymbol*> *rsymb) {}

  inline void Print(ostream&os, int indent) {
    PUT_SPACE(indent);
    os << "for (";
    _fmr_lexp->Print(os); 
    os << " = ";
    _fmr_rexp->Print(os); 
    os << "; ";
    _mid_exp->Print(os);
    os << "; ";
    _lst_lexp->Print(os);
    os << " = ";
    _lst_rexp->Print(os);
    os << ")" << endl;
    _stmt->Print(os, indent+step);
  }
    
};

class CStmtIF : public CStatement
{
private:
  CExpression* _cond;
  CStatement*  _if_stmt;
  CStatement*  _else_stmt;

  inline CStmtIF() : CStatement() {}

public:
  inline CStmtIF(CExpression *cond, CStatement *if_stmt, CStatement *else_stmt) : 
    CStatement(), _cond (cond), _if_stmt (if_stmt), _else_stmt (else_stmt) {}

  inline CStmtIF(CExpression *cond, CStatement *if_stmt, CStatement *else_stmt, int step_) : 
    CStatement(step_), _cond (cond), _if_stmt (if_stmt), _else_stmt (else_stmt) {}


  inline CStmtIF(CExpression *cond, CStatement *if_stmt) : 
    CStatement(), _cond (cond), _if_stmt (if_stmt), _else_stmt (NULL) {}

  inline CStmtIF(CExpression *cond, CStatement *if_stmt, int step_) : 
    CStatement(step_), _cond (cond), _if_stmt (if_stmt), _else_stmt (NULL) {}


public:
  inline void Print(ostream&os=cout, int indent=0) {
    PUT_SPACE(indent);
    os << "if ( ";  
    _cond->Print(os); 
    os << " ) begin" << endl;
    _if_stmt->Print(os, indent+step); 
    PUT_SPACE(indent);
    os << "end" << endl;

    if ( _else_stmt ) {
      PUT_SPACE(indent);
      os << "else begin" << endl;
      _else_stmt->Print(os, indent+step); 
      PUT_SPACE(indent);
      os << "end" << endl;
    }
  }

  inline void GetSymbol(set<CSymbol*> *lsymb, set<CSymbol*> *rsymb) {
#if 0
    _cond->GetSymbol(rsymb);
    _if_stmt->GetSymbol(lsymb, rsymb);
    if (_else_stmt ) _else_stmt->GetSymbol(lsymb, rsymb);
#endif
  }
  
};



class CStmtBunch : public CStatement
{
private:
  vector<CStatement*> *_stmt_list;
  
  inline CStmtBunch() : CStatement(), _stmt_list (NULL) {}

public:
  inline CStmtBunch(vector<CStatement*> *stmt_list) : 
    CStatement(), _stmt_list (stmt_list) {}

  inline CStmtBunch(vector<CStatement*> *stmt_list, int step_) : 
    CStatement(step_), _stmt_list (stmt_list) {}

public:
  inline void Print(ostream&os=cout, int indent=0) {
    for ( vector<CStatement*>::iterator iter = _stmt_list->begin(); 
	  iter != _stmt_list->end(); ++iter) {
      (*iter)->Print(os, indent);
    }
  }

  inline void GetSymbol(set<CSymbol*> *lsymb, set<CSymbol*> *rsymb) {
#if 0
    for ( vector<CStatement*>::iterator iter = _stmt_list->begin(); 
	  iter != _stmt_list->end(); ++iter) {
      (*iter)->GetSymbol(lsymb, rsymb);
    }
#endif
  }
    
};


class CCaseItem
{
private:
  int _step;

  vector<CExpression*> *_cond;
  CStatement*  _stmt;

  inline CCaseItem() {}

public:
  inline CCaseItem(vector<CExpression*> *cond, CStatement *stmt) : 
    _cond (cond), _stmt (stmt), _step (2) {}

  inline CCaseItem(vector<CExpression*> *cond, CStatement *stmt, int step) : 
    _cond (cond), _stmt (stmt), _step (step) {}

  inline CCaseItem(CExpression *cond, CStatement *stmt) : 
    _stmt (stmt), _step (2) {
     _cond = new vector<CExpression*>;
     _cond->push_back(cond);
  }

  inline CCaseItem(CExpression *cond, CStatement *stmt, int step) : 
     _stmt (stmt), _step (step) {
     _cond = new vector<CExpression*>;
     _cond->push_back(cond);
  }


  inline void Print(ostream &os=cout, int indent=0) {
    PUT_SPACE(indent);
    for (vector<CExpression*>::iterator iter = _cond->begin(); 
         iter != _cond->end(); ++iter) {
      (*iter)->Print(os);
      if ( iter != _cond->end()-1 ) os << ", ";
    }
    os << " : begin" << endl;
    _stmt->Print(os, indent+_step); 
    PUT_SPACE(indent);
    os << "end" << endl;
  }

  inline void GetSymbol(set<CSymbol*> *lsymb, set<CSymbol*> *rsymb) {
#if 0
    for (vector<CExpression*>::iterator iter = _cond->begin(); 
         iter != _cond->end(); ++iter ) {
      (*iter)->GetSymbol(rsymb);
    }
    _stmt->GetSymbol(lsymb, rsymb);
#endif
  }

};

class CCaseType
{
public: 
  string ctype;
  bool z;

public: 
  inline CCaseType() {ctype = "", z = false;}
  inline CCaseType(const string &s, const bool &b) {ctype = s, z = b;}
    
};

class CStmtCASE : public CStatement
{
private:
  string _type;
  bool _z; 
  CExpression* _exp;
  vector<CCaseItem*> *_items;
  CStatement* _default_stmt;

  inline CStmtCASE () {}

public:
  inline CStmtCASE(CCaseType *case_type, CExpression* exp, vector<CCaseItem*> *items) : 
    CStatement(), _type (case_type->ctype), _z (case_type->z), _exp (exp), _items (items), _default_stmt (NULL) {}

  inline CStmtCASE(CCaseType *case_type, CExpression* exp, vector<CCaseItem*> *items, CStatement* default_stmt) : 
    CStatement(), _type (case_type->ctype), _z (case_type->z), _exp (exp), _items (items), _default_stmt (default_stmt) {}

  inline CStmtCASE(CCaseType *case_type, CExpression* exp, vector<CCaseItem*> *items, int step_) : 
    CStatement(step_), _type (case_type->ctype), _z (case_type->z), _exp (exp), _items (items), _default_stmt (NULL) {}

  inline CStmtCASE(CCaseType *case_type, CExpression* exp, vector<CCaseItem*> *items, CStatement* default_stmt, int step_) : 
    CStatement(step_), _type (case_type->ctype), _z (case_type->z), _exp (exp), _items (items), _default_stmt (default_stmt) {}


  inline void Print(ostream &os=cout, int indent=0) {
    // PUT_SPACE(indent);
    if ( LEGACY_VERILOG_MODE && (_type != "") ) {
      if ( CASE_MODIFY_STYLE == PROPAGATE ) {
	PUT_SPACE(indent);
	os << _type << " case";
	if ( _z ) os << "z";
	os << " (";
	_exp->Print(os);
	os << " ) " << endl;
      }
      else if (CASE_MODIFY_STYLE == MACRO ) {
	os << "`ifdef USE_UNIQUE" << endl;
	PUT_SPACE(indent);
	os << _type << " " << "case";
	if ( _z ) os << "z";
	os << " (";
	_exp->Print(os);
	os << " ) " << endl;
	os << "`else" << endl;
	PUT_SPACE(indent);
	os << "case";
	if (_z) os << "z";
	os << " (";
	_exp->Print(os);
	os << " ) " << endl;
	os << "`endif" << endl;
      }
      else { // Eliminate
	PUT_SPACE(indent);
	os << "case";
	if ( _z ) os << "z";
      
	os << " ( " ; 
	_exp->Print(os);
	os << " ) " << endl;
      }
    }
    else {
      PUT_SPACE(indent);
      os << _type << " case"; 
      if ( _z ) os << "z"; 
      os << " ( ";
      _exp->Print(os);
      os << " )" << endl;
    }

    for (vector<CCaseItem*>::iterator iter = _items->begin(); 
	 iter != _items->end(); ++iter) {
      (*iter)->Print(os, indent+step);
      if (iter + 1 != _items->end())
	os << endl;
    }
    
    if ( _default_stmt ) {
      os << endl;
      PUT_SPACE(indent+step);
      os << "default: begin" << endl;
      _default_stmt->Print(os, indent+step*2);
      PUT_SPACE(indent+step);
      os << "end" << endl;
    }

    PUT_SPACE(indent);
    os << "endcase" << endl
       << endl;
  }

  inline void GetSymbol(set<CSymbol*> *lsymb, set<CSymbol*> *rsymb) {
#if 0
    _exp->GetSymbol(rsymb);
    for (vector<CCaseItem*>::iterator iter = _items->begin(); 
	 iter != _items->end(); ++iter) {
      (*iter)->GetSymbol(lsymb, rsymb);
    }
    if ( _default_stmt ) {
      _default_stmt->GetSymbol(lsymb, rsymb);
    }
#endif
  }


};

class CStmtVerbatim : public CStatement
{
private:
  string _str;

public:
  inline CStmtVerbatim (const string &str) : _str (str) {}

  inline void Print(ostream&os=cout, int indent=0) {
    PUT_SPACE(indent); 
    os << _str << endl;
  }

  inline void GetSymbol(set<CSymbol*> *lsymb, set<CSymbol*> *rsymb) {}
};


class CStmtSelfInc : public CStatement
{
private:
  CArithMacro *_lval;
  
public:
  inline CStmtSelfInc(CArithMacro *lval) : _lval (lval) {}

  inline virtual void Evaluate() {_lval->SetValue( new CNumber(_lval->Value() + 1));}
  inline virtual void Print(ostream &os=cout, int indent=0) {}
  inline virtual void GetSymbol(set<CSymbol*> *lsymb, set<CSymbol*> *rsymb) {}
};


class CStmtSelfDec : public CStatement
{
private:
  CArithMacro *_lval;

public:
  inline CStmtSelfDec(CArithMacro *lval) : _lval (lval) {}

  inline virtual void Evaluate() {_lval->SetValue( new CNumber(_lval->Value() - 1));}
  inline virtual void Print(ostream &os=cout, int indent=0) {}
  inline virtual void GetSymbol(set<CSymbol*> *lsymb, set<CSymbol*> *rsymb) {}
};



#endif
