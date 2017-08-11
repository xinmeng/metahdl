#ifndef __EXPRESSION_HH__
#define __EXPRESSION_HH__

#include "Mfunc.hh"
#include "CMacro.hh"
#include "string.h"
#include "ExpressionBase.hh"


// enum tDirection {INPUT, OUTPUT, INOUT, NONPORT};
// enum tType {WIRE, REG, LOGIC, INT, INTEGER};
// class CSymbol;

// ------------------------------
//   Base class
// ------------------------------
// class CExpression
// {
// public: 
//   inline CExpression() {};

// public:
//   virtual bool         IsConst()  = 0;
//   virtual ulonglong    Width()  = 0;
//   virtual ulonglong    Value()  = 0;
//   virtual CExpression* ValueExp() =0;
//   virtual CExpression* Reduce()  =0;
//   virtual void         Print(ostream& os=cout)  =0;
//   virtual inline void  GetSymbol(set<CSymbol*> *) {}
//   virtual bool         HasParam() =0;
//   virtual bool         Update(tDirection direction) =0;
//   virtual void         AddRoccure(yy::location loc) =0;
//   virtual void         AddLoccure(yy::location loc) =0;
//   virtual bool         Update(tType) =0;

// };


// ------------------------------
//   CConstant
// ------------------------------
class CConstant : public CExpression
{
protected:
  ulonglong _width;
  ulonglong _value;

public:
  inline CConstant() {}
  inline CConstant(ulonglong width, ulonglong value) : _width (width), _value (value) {};
  
public:
  inline bool IsConst() {return true;}

  virtual inline ulonglong Width() {return _width;}
  virtual inline double    DoubleValue() {return (double) Value();}
  virtual inline ulonglong Value() {return _value;}
  virtual inline CConstant* ValueExp() {return this;}


  virtual void Print(ostream& os=cout) =0;
  virtual CExpression* Reduce()  = 0;

  inline virtual bool HasParam() {return false;}

  inline virtual bool Update(tDirection direction) {return true;}
  inline virtual void AddLoccure(yy::location loc) {}
  inline virtual void AddRoccure(yy::location loc) {}
  inline virtual bool Update(tType new_type)  {return false;}

public:
  inline virtual string BinStr(int width=-1) {
    return ItoS(_value, width, 2);
  }

  inline virtual ulonglong CalcWidth(ulonglong val) {
    double logval =  log(val)/log(2);
    ulonglong i_logval = (ulonglong) logval;

    if ( val == 0 ) {
      return 1;
    }
    else {
      return i_logval + 1;
    }
  }
};

class CNumber : public CConstant
{
public: 
  inline CNumber(const string &str) {_value = StoI(str); _width = 32; }
  inline CNumber(const string &str, int base) {_value = StoI(str, base); _width=32; }
  inline CNumber(ulonglong value): CConstant(32, value) {}
  inline CNumber(ulonglong width, ulonglong value) : CConstant(width, value) {};
    

public:
  inline void Print(ostream&os=cout) {os << _value;}
  inline CNumber* Reduce()  {return this;}

};


class CBasedNum : public CConstant
{
private: 
  string _str;

public:
  inline CBasedNum(const string &str, int base) : _str (str) {
    size_t q_pos = str.find_first_of("'");
    _width = StoI(str.substr(0, q_pos), 10);

    size_t xz_pos = str.find_first_of("xXzZ");
    ulonglong _value_num;
    if ( xz_pos == string::npos ) {
      _value = StoI(str.substr(q_pos+2), base);
      string bin_str = BinStr();
      if (bin_str.length() > _width) {
	ostringstream sstr;
	sstr << _str << " needs " << bin_str.length() << " bits, " << _width << " is not enough.";
	throw sstr.str();
      }
    }
    else {
      _value = 0;
    }
  }
  
  inline void Print(ostream&os=cout) {os << _str;}
  inline CBasedNum* Reduce() {return this;}
};



// ------------------------------
//   const number
// ------------------------------
extern CNumber* CONST_NUM_0;


// ------------------------------
//  CString
// ------------------------------
class CString : public CConstant
{
private:
  string _str;
  
public:
  inline CString() : CConstant(1,1), _str ("") {}
  inline CString(const string &str) : CConstant(0,0) , _str (str) {}

  inline virtual void Print(ostream &os=cout) {os<<"\""<<_str<<"\"";}
  inline virtual CExpression* Reduce() {return this;}

  inline virtual string BinStr(int width=-1) {return _str;}
  inline virtual ulonglong CalcWidth(ulonglong val) {return 1;}


  inline virtual double    DoubleValue() {throw "Internal Error: Unexpected call to CString::DoubleValue().";}
  inline virtual ulonglong Value() {throw "Internal Error: Unexpected call to CString::Value().";}
  inline virtual ulonglong Width() {throw "Internal Error: Unexpected call to CString::Width().";}
  
};


// ------------------------------
//   CSymbol
// ------------------------------
class CSymbol
{
public:
  string name;
  CExpression* msb;
  CExpression* lsb;
  tDirection direction;
  tType type;
  bool type_fixed;
  bool force_port;
  bool io_fixed;
  bool width_fixed;
  bool is_2D;
  CExpression* length_msb;
  bool is_const;
  bool is_local;
  CExpression* value;

#if 0
  vector<CCodeBlock*> driver;
#endif

  vector<yy::location> loccur, roccur;
  CSymbol *reference;
  
  
public:
  inline CSymbol(const string &name_) : 
    name (name_), msb (CONST_NUM_0), lsb (CONST_NUM_0), direction (NONPORT), type (WIRE), 
    type_fixed (false), force_port (false), io_fixed (false), width_fixed (false),
    is_2D (false), length_msb (NULL),
    is_const (false), is_local (false), value (NULL),  reference (NULL) {}
  
  inline CSymbol(const string &name_, CExpression* msb_) :
    name (name_), msb (msb_), lsb (CONST_NUM_0), direction (NONPORT), type (WIRE),
    type_fixed (false), force_port (false), io_fixed (false), width_fixed (false), 
    is_2D (false), length_msb (NULL),
    is_const (false), is_local (false), value (NULL),  reference (NULL)  {}    
    
  inline CSymbol(const string &name_, CExpression* msb_, tType type_) :
    name (name_), msb (msb_), lsb (CONST_NUM_0), direction (NONPORT), type (type_),
    type_fixed (false), force_port (false), io_fixed (false), width_fixed (false), 
    is_2D (false), length_msb (NULL),
    is_const (false), is_local (false), value (NULL),  reference (NULL)  {}    


  inline CSymbol(const string &name_, CExpression* msb_, CExpression* length_msb_, tType type_) :
    name (name_), msb (msb_), lsb (CONST_NUM_0), direction (NONPORT), type (type_),
    type_fixed (false), force_port (false), io_fixed (false), width_fixed (false), 
    is_2D (true), length_msb (length_msb_),
    is_const (false), is_local (false), value (NULL),  reference (NULL)  {}    


  inline CSymbol(const string &name_, CExpression* msb_, tDirection direction_) :
    name (name_), msb (msb_), lsb (CONST_NUM_0), direction (direction_), type (WIRE),
    io_fixed (false), width_fixed (false), 
    is_2D (false), length_msb (NULL),
    is_const (false), is_local (false), value (NULL),  reference (NULL)  {}    

  inline CSymbol(const string &name_, CExpression* msb_, tDirection direction_, CSymbol* reference_) :
    name (name_), msb (msb_), lsb (CONST_NUM_0), direction (direction_), type (WIRE),
    type_fixed (false), force_port (false), io_fixed (false), width_fixed (false), 
    is_const (false), is_local (false), value (NULL),  reference (reference_)  {
      is_2D = reference_->is_2D;
      if (reference_->is_2D)
          length_msb = reference_->length_msb;
      else 
          length_msb = NULL;
  }    



  inline void PrintPort(ostream &os=cout) {
    os.width(8);
    os << left;
    if ( direction == NONPORT ) {
      return ;
    }
    else {
      switch (direction) {
      case INPUT:   os << "input "; break;
      case OUTPUT:  os << "output "; break;
      case INOUT:   os << "inout ";  break;
      }
    
      if (is_2D ) PrintWidth(os, length_msb, CONST_NUM_0);
      PrintWidth(os, msb, lsb);
      os << name;
      os << ";" << endl;
      
    }
    os.width(0);
  }

  inline void PrintDeclare(ostream &os=cout) {
    if ( LEGACY_VERILOG_MODE ) {
      if (is_const ) {
          if (is_local)
              os << "localparam ";
          else 
              os << "parameter ";
          os << name << " = ";
          value->Print(os);
          os << ";" << endl;
      }
      else {
	os.width(8);
	os << left;		
	switch (type) {
	case REG:
            os << "reg ";
            if (is_2D ) PrintWidth(os, length_msb, CONST_NUM_0);
            PrintWidth(os, msb, lsb);
            break;

	case WIRE:
            os << "wire ";
            if (is_2D ) PrintWidth(os, length_msb, CONST_NUM_0);
            PrintWidth(os, msb, lsb);
            break;

	case LOGIC:
            os << "logic ";
            if (is_2D ) PrintWidth(os, length_msb, CONST_NUM_0);
            PrintWidth(os, msb, lsb);
            break;
            
	case INT:     os << "int "; break;
	case INTEGER: os << "integer "; break; 
	}
	os.width(0);

	os << name;

	
	os << ";" << endl;
      }
    }
    else {
      if ( is_const ) os << "const "; 

      os.width(8);
      os << left;
      switch (type) {
      case REG:     os << "reg "; PrintWidth(os, msb, lsb); break;
      case WIRE:    os << "wire "; PrintWidth(os, msb, lsb); break;
      case LOGIC:   os << "logic "; PrintWidth(os, msb, lsb); break;
      case INT:     os << "int "; break;
      case INTEGER: os << "integer "; break; 
      }
      os.width(0);

      os << name;

      if (is_2D ) PrintWidth(os, length_msb, CONST_NUM_0);

      if (is_const ) {
	os << " = ";
	value->Print(os);
      }
      os << ";" << endl;
    }

    if (is_2D) {
      os << "`ifdef FSDB_MDA_ENABLE" << endl
	 << "// synopsys translate_off" << endl
	 << "`FSDB_DUMP_BEGIN" << endl
	 << "  `fsdbDumpMDA(" << name << ");" << endl
	 << "`FSDB_DUMP_END" << endl
	 << "// synopsys translate_on" << endl
	 << "`endif" << endl
	 << endl;
    }

  }


  inline bool Update(tDirection direction_) {
    if ( io_fixed || is_const ) {
      return false;
    }
    else {
      if ( direction == INOUT ) {
      }
      else if ( direction != NONPORT && 
		direction != direction_ ) {
	direction = NONPORT;
	io_fixed = true;
      }
      else {
	direction = direction_;
      }
      return true;
    }
  }

  inline bool Update(CExpression* msb_) {
    if (width_fixed || is_const || is_2D ) {
       if ( msb_->Value() <= msb->Value() ) {
	  return true;
       }
       else {
	  return false;
       }
    }
    else {
      if ( (msb_->Value() == msb->Value() && msb_->HasParam()) || 
	   (msb_->Value() > msb->Value()) ) {
	msb = msb_;
      }
      return true;
    }
  }

  inline bool UpdateLSB(CExpression *lsb_)
  {
    // only invoked by port/variable declarations 
    if ( width_fixed || is_const || is_2D ) {
      return false;
    }
    else {
      if ( lsb_->Value() > msb->Value() ) {
	return false;
      }
      else {
	lsb = lsb_;
      
	return true;
      }
    }
  }

  inline void PrintOccurence(ostream&os=cout) {
     os << "R-occur of " << name << endl;
     for (vector<yy::location>::iterator iter = roccur.begin();
	  iter != roccur.end(); ++iter) {
	os << *iter << endl;
     }

     os << "L-occur of " << name <<endl;
     for (vector<yy::location>::iterator iter = loccur.begin();
	  iter != loccur.end(); ++iter) {
	os << *iter << endl;
     }
  }


  inline bool Update(tType new_type) {
    if ( type_fixed ) {
      return false;
    }
    else if ( type >= new_type ) {
      return false;
    }
    else {
      type = new_type;
      return true;
    }
    
  }


private:
  inline void PrintWidth(ostream &os, CExpression* msb_, CExpression* lsb_) {
    // avoid declaring 1-bit signal in [0:0] style
    if ( msb_->Value() == 0 && !msb_->HasParam() ) {
      os << "          ";
    }
    else {
      os << "[";

      os.width(4);
      if (msb_->HasParam()) {
	msb_->Print(os);
      }
      else if ( msb_->Value() != 0 ) {
	msb_->Reduce()->Print(os);
      }
      else /* if ( msb_ != CONST_NUM_0 ) */ {
	os << "0";
      }

      os.width(0);
      os << ":";
    
      if (lsb_->HasParam()) {
	lsb_->Print(os);
      }
      else if ( lsb_->Value() != 0 ) {
	lsb_->Reduce()->Print(os);
      }
      else /* if ( lsb_ != CONST_NUM_0 )*/ {
	os << "0";
      }

      os << "]  ";
    }
  }
    
};

struct CCompareConnection 
{
  inline bool operator() (CSymbol* i, CSymbol* j) {
    if ( strcmp(i->name.c_str(), j->name.c_str()) < 0 ) {
      return true;
    }
    else {
      return false;
    }
  }
};



#if 0
// ------------------------------
//   CNet
// ------------------------------
class CNet : public CExpression
{
public:
  inline CNet() {}

  virtual inline bool IsConst() = 0;
  virtual inline ulonglong Width()  = 0;
  virtual inline ulonglong Value()  = 0;
  virtual inline CExpression* ValueExp() = 0;
  virtual inline CExpression* Reduce() =0;
  virtual inline void Print(ostream&os=cout) = 0;

  virtual inline bool Update(tDirection direction) {};
  virtual inline bool Update(CExpression *msb) {};
  virtual inline void GetSymbol(set<CSymbol*> *) {};
  
  virtual inline void AddLoccure(yy::location loc) {};
  virtual inline void AddRoccure(yy::location loc) {};
  
  virtual bool Update(tType) =0;

  virtual bool HasParam() =0;

};
#endif



class CParameter : public CExpression
{
private:
  string _name;
  CExpression* _value;
  CExpression* _override;

public:
  bool   global;
  


public: 
  inline CParameter(const string &name, CExpression* value, bool type) : 
    _name (name), _value (value), global (type), _override (NULL) {}

public: 
  virtual inline void AddLoccure(yy::location loc) {};
  virtual inline void AddRoccure(yy::location loc) {};

  inline bool IsConst() {return true;}

  inline ulonglong Width() {
    if ( _override ) 
      return _override->Width();
    else 
      return _value->Width();
  }

  inline virtual double DoubleValue() {return (double) Value();}

  inline ulonglong Value() {
    if ( _override ) 
      return _override->Value();
    else 
      return _value->Value();
  }

  inline CExpression* DefinitionExp() {return _value;}

  inline CExpression* ValueExp() {
    if ( _override ) {
      return _override;
    }
    else {
      return _value->ValueExp();
    }
  }

  inline CExpression* Reduce()  {
    if ( _override ) {
      return new CNumber (_override->Width(), _override->Value());
    }
    else {
      return new CNumber (_value->Width(), _value->Value());
    }
  }

  inline void Print(ostream&os=cout) {os << _name;}
  inline bool Update(tDirection direction) {return true;}
  inline bool Update(CExpression*msb) {return true;}
  inline bool Update(tType new_type) {return false;}

  inline string Name() {return _name;}

  inline bool SetValue(CExpression* override) {
    if (global) {
      _override = override;
      return true;
    }
    else {
      return false;
    }
  }
  
  inline bool HasParam() {return true;}

};


class CVariable : public CExpression
{
private:
  bool _is_2D;
  CSymbol *_symbol;
  CExpression *_addr;
  CExpression *_msb, *_lsb;

public:
    inline CVariable( CSymbol *symbol, 
                      CExpression *addr=NULL, 
                      CExpression *msb=NULL, CExpression *lsb=NULL) :
        _is_2D (symbol->is_2D), _symbol (symbol) {
        if (_is_2D) {
            _addr = addr;
            _msb  = msb;
            _lsb  = lsb;
        }
        else {
            _msb = addr;
            _lsb = msb;
        }
        // cout << "VAR: " << _symbol->name << " created" << endl
        //      << _is_2D << " vs. " << _symbol->is_2D << endl
        //      << _addr << endl;
        // Print(cout);
        // cout << endl;
    }

  // inline CVariable( bool is_2D, CSymbol *symb, CExpression *addr, CExpression *msb) : 
  //   _is_2D (is_2D), _addr (addr), _symbol (symb), _msb (msb), _lsb (NULL)  {}

  // inline CVariable( bool is_2D, CSymbol *symb, CExpression *addr, CExpression *msb, CExpression *lsb) : 
  //   _is_2D (is_2D), _addr (addr), _symbol (symb), _msb (msb), _lsb (lsb)  {}

  inline bool IsConst() {return _symbol->is_const;}
  inline ulonglong Width() {
      if ( _msb && _lsb ) {
          return _msb->Value() - _lsb->Value() + 1;
      }
      else if (_msb) {
          return 1;
      }
      else {
          return _symbol->msb->Value() +1 ;
      }
  }

  inline virtual double DoubleValue() {return _symbol->value->DoubleValue();}

  inline ulonglong Value() {
    if ( IsConst() ) {
      return _symbol->value->Value();
    }
    else {
        return 1;
      // cerr << "**MHDL Internal Error:Unable to get value from a variable:";
      // Print(cerr);
      // exit(1);
    }
  }
  
  inline CExpression* ValueExp() {
    if ( _symbol->is_const ) {
      return _symbol->value->ValueExp();
    }
    else {
      return this;
    }
  }


  inline CExpression* Reduce() {
    if ( IsConst() ) 
      return _symbol->value->Reduce();
    else 
      return NULL;
  }

  inline void Print(ostream& os=cout) {
    os << _symbol->name;

    if (_is_2D && _addr) {
      os << "[";
      _addr->Print(os);
      os << "]";
    }
    
    
    if ( !_symbol->is_const 
	 && !_msb && FORCE_WIDTH_OUTPUT && (_symbol->msb->Value() > 0 || _symbol->msb->HasParam()) ) {
      os << "[";
      _symbol->msb->Print(os);
      os << ":";
      _symbol->lsb->Print(os);
      os << "]";
    }
    else if ( _msb ) {
      os << "[";
      _msb->Print(os);
      
      if (_lsb) {
	os << ":";
	_lsb->Print(os);
	os << "]";
      }
      else {
	os << "]";
      }
    }

//     if ( _is_2D ) {
//        os << "[";
//        _addr->Print(os);
//        os << "]";
//        os << "[";
//        _msb->Print(os);
//        if ( _lsb ) {
// 	  os << ":";
// 	  _lsb->Print(os);
//        }
//        os << "]";
//     }
//     else {
//        if (_msb) {
// 	  os << "[";
// 	  _msb->Print(os);

// 	  if ( _lsb ) {
// 	     os << ":"; 
// 	     _lsb->Print(os);
// 	     os << "]";
// 	  }
// 	  else {
// 	     os << "]";
// 	  }
//        }
//     }
  }

  inline bool HasParam() {return false;}

  inline bool Update(tType new_type) {return _symbol->Update(new_type);}
  inline bool Update(tDirection direction) { return _symbol->Update(direction);}
  inline bool Update(CExpression *msb) {return _symbol->Update(msb);}

  inline CSymbol* Symb() {return _symbol;}
  inline CExpression* Addr() {return _addr;}
  inline CExpression* Msb() {return _msb;}
  inline CExpression* Lsb() {return _lsb;}
  inline void GetSymbol(set<CSymbol*> *st) {
#if 0
     st->insert(_symbol);
     if (_msb) _msb->GetSymbol( st );
     if (_lsb )_lsb->GetSymbol( st );
#endif
  }

  inline void AddLoccure(yy::location loc) {_symbol->loccur.push_back(loc);}

  inline void AddRoccure(yy::location loc) {_symbol->roccur.push_back(loc);}

};



// ------------------------------
//   CTrinaryExp
// ------------------------------
class CTrinaryExp : public CExpression
{
private:
  CExpression* _cond;
  CExpression* _t_opt;
  CExpression* _f_opt;
  
public:
  inline CTrinaryExp(CExpression* cond, CExpression* t_opt, CExpression* f_opt) : 
    _cond (cond), _t_opt (t_opt), _f_opt (f_opt) {};


  inline bool IsConst() {
    return _cond->IsConst() && _t_opt->IsConst() && _f_opt->IsConst();
  }

  inline ulonglong Width() {
    return Max(_t_opt->Width(), _f_opt->Width());
  }

  inline double DoubleValue() {return _cond->Value() ? _t_opt->DoubleValue() : _f_opt->DoubleValue();}

  inline ulonglong Value() {
    return _cond->Value() ? _t_opt->Value() : _f_opt->Value();
  }

  inline CTrinaryExp* ValueExp() {
    return new CTrinaryExp ( _cond->ValueExp(), _t_opt->ValueExp(), _f_opt->ValueExp());
  }

  inline  CNumber* Reduce() {
    if ( IsConst() ) {
      ulonglong val;
      if ( _cond->Value() ) 
	val = _t_opt->Value();
      else
	val = _f_opt->Value();
      return new CNumber (Width(), val);
    }
    else {
      return NULL;
    }
  }

  inline void Print(ostream& os=cout) {
    _cond->Print(os);  os << " ? ";
    _t_opt->Print(os); os << " : ";
    _f_opt->Print(os); 
  }

  inline void GetSymbol(set<CSymbol*> *st) {
#if 0
    _cond->GetSymbol(st);
    _t_opt->GetSymbol(st);
    _f_opt->GetSymbol(st);
#endif
  }

  inline bool HasParam() {
    return
      _cond->HasParam() || 
      _t_opt->HasParam() || 
      _f_opt->HasParam();
  }

  inline virtual bool Update(tDirection direction) {
    bool flag = true;
    flag = _cond->Update(direction) && flag;
    flag = _t_opt->Update(direction) && flag;
    flag = _f_opt->Update(direction) && flag;

    return flag;
  }

  inline bool Update(tType new_type) {return false;}

  inline virtual void AddRoccure(yy::location loc) {
    _cond->AddRoccure(loc);
    _t_opt->AddRoccure(loc);
    _f_opt->AddRoccure(loc);
  }

  inline virtual void AddLoccure(yy::location loc) {
    _cond->AddLoccure(loc);
    _t_opt->AddLoccure(loc);
    _f_opt->AddLoccure(loc);
  }

};


// ------------------------------
//    CFuncCallExp
// ------------------------------
class CFuncCallExp : public CExpression
{
private:
  string _func_name;
  vector<CExpression*> *_args;

public:
  inline CFuncCallExp (const string &func_name, vector<CExpression*> *args) :
    _func_name (func_name), _args (args) {}

public:
  inline bool         IsConst() {
      if (_func_name == "log2") {
          for (vector<CExpression*>::iterator iter=_args->begin(); iter!=_args->end();
               iter++)
              if (!(*iter)->IsConst()) {
                  cerr << "log2 function called on non-constant argument: ";
                  (*iter)->Print(cerr);
                  return false;
              }
          return true;
      }
      else 
          return false; 
  }

  inline ulonglong    Width() {
      if (_func_name == "log2") 
          return 32;
      else 
          return 1;
  }

  inline double       DoubleValue() {
      if (_func_name == "log2" ) {
          CExpression * arg = (*_args)[0];
          if (arg->IsConst())
              return log2(arg->DoubleValue());
          else {
              cerr << "**Internal Error:"<< __FILE__ << ":" << __LINE__ << ":Try to call log2 on non-constant argument: ";
              arg->Print(cerr);
              exit(1);
          }              
      }
      else {
          cerr << "**Internal Error:"<< __FILE__ << ":" << __LINE__ << ":Try to call DoubleValue() from CFuncCallExp!"; 
          exit(1);
      }
  }
  inline ulonglong    Value() {
      if (_func_name == "log2")
          return ceil(this->DoubleValue());
      else {
          cerr << "**Internal Error:"<< __FILE__ << ":" << __LINE__ << ":Try to call Value() from CFuncCallExp!"; 
          exit(1);
      }
  }

  inline CExpression* ValueExp() {
      vector<CExpression*> *val_exp_args = new vector<CExpression*>;
      for (vector<CExpression*>::iterator iter=_args->begin(); iter!=_args->end(); 
           iter++)
          val_exp_args->push_back((*iter)->ValueExp());
      return new CFuncCallExp(_func_name, val_exp_args);
  }
  inline CExpression*  Reduce() {
      if (_func_name == "log2") {
          return new CNumber(32, Value());          
      }
      else {
          cerr << "**Internal Error:"<< __FILE__ << ":" << __LINE__ << ":Try to call Reduce() from CFuncCallExp!"; 
          exit(1);
      }
  }

  inline void Print(ostream& os=cout) {
    os << _func_name << "(";
    for ( vector<CExpression*>::iterator iter = _args->begin(); 
	  iter != _args->end(); ++iter) {
      (*iter)->Print(os);
      if ( iter != _args->end() -1 ) os << ", ";
    }
    os<<")";
  }

  inline void GetSymbol(set<CSymbol*> *st) {
#if 0
    for ( vector<CExpression*>::iterator iter = _args->begin(); 
	  iter != _args->end(); ++iter) {
      (*iter)->GetSymbol(st);
    }
#endif
  }

  inline bool HasParam() {
    for ( vector<CExpression*>::iterator iter = _args->begin(); 
	  iter != _args->end(); ++iter) {
      if ( (*iter)->HasParam() ) return true;
    }
    return false;
  }

  inline virtual bool Update(tDirection direction) {
    bool flag = true;
    for (vector<CExpression*>::iterator iter = _args->begin();
	 iter != _args->end(); ++iter) {
      flag = (*iter)->Update(direction) && flag;
    }
    return flag;
  }

  inline bool Update(tType new_type) {return false;}

  inline virtual void AddRoccure(yy::location loc) {
    for (vector<CExpression*>::iterator iter = _args->begin();
	 iter != _args->end(); ++iter) {
      (*iter)->AddRoccure(loc);
    }
  }

  inline virtual void AddLoccure(yy::location loc) {
    cerr << "**Internal Error:" << __FILE__ << ":" << __LINE__
	 << ":try to set arguments of function call to LHS variable." << endl;
    exit(1);
  }
};


// ------------------------------
//   CMppFuncCall
// ------------------------------
class CMppFuncCall : public CExpression
{
private:
  string _func_name;
  vector<CExpression*> *_arg_values;

public:
  inline virtual bool         IsConst()  {return true;}
  inline virtual ulonglong    Width()  {return 32;}
  inline virtual double       DoubleValue() {return MppBuildInFunc(_func_name, _arg_values);}
  inline virtual ulonglong    Value()  {return (ulonglong) DoubleValue();}
  inline virtual CExpression* ValueExp() {return this;}
  inline virtual CExpression* Reduce() {return new CNumber(Width(), Value());}
  inline virtual void         Print(ostream& os=cout)  {
    os << _func_name << "(";
    for (vector<CExpression*>::iterator iter=_arg_values->begin();
	 iter != _arg_values->end(); iter++) {
      (*iter)->Print(os);
      if (iter != _arg_values->end() -1 ) os << ", ";
    }
    os << ")";
  }
  inline virtual void  GetSymbol(set<CSymbol*> *) {}
  inline virtual bool  HasParam() {return false;}
  inline virtual bool  Update(tDirection direction) {};
  inline virtual void  AddRoccure(yy::location loc) {};
  inline virtual void  AddLoccure(yy::location loc) {};
  inline virtual bool  Update(tType) {};
  
};


// ------------------------------
//   CParenthExp
// ------------------------------
class CParenthExp : public CExpression
{
private:
  CExpression* _exp;
  
public:
  inline CParenthExp(CExpression* exp) : _exp (exp) {};
  
public:
  inline bool         IsConst() {return _exp->IsConst(); }
  inline ulonglong    Width() {return _exp->Width();}
  inline double       DoubleValue() {return _exp->DoubleValue();}
  inline ulonglong    Value() {return _exp->Value();}
  inline CParenthExp* ValueExp() {return new CParenthExp (_exp->ValueExp());}
  inline CExpression* Reduce() {return IsConst() ? _exp->Reduce() : NULL;}
  inline void         Print(ostream& os=cout) {os << "(";_exp->Print(os);os<<")";}
  inline void         GetSymbol(set<CSymbol*> *st) {
#if 0
    _exp->GetSymbol(st);
#endif
  }
  inline bool         HasParam() {return _exp->HasParam();}

  inline virtual bool Update(tDirection direction) {return _exp->Update(direction);}
  inline bool Update(tType new_type) {return false;}
  inline virtual void AddRoccure(yy::location loc) {_exp->AddRoccure(loc);}
  inline virtual void AddLoccure(yy::location loc) {_exp->AddLoccure(loc);}
};


// ------------------------------
//   CConcatenation
// ------------------------------
class CConcatenation : public CExpression
{
private:
  vector<CExpression*> *_exp_list;
  
public: 
  inline CConcatenation(vector<CExpression*>* exp_list) : 
    _exp_list (exp_list) {};
  
public:
  virtual inline bool IsConst() {
    for ( vector<CExpression*>::iterator iter = _exp_list->begin(); 
	  iter != _exp_list->end(); ++iter) {
      if ( (*iter)->IsConst() ) continue;
      else return false;
    }
    return true;
  }

  virtual inline ulonglong Width() {
    ulonglong width = 0;
    for ( vector<CExpression*>::iterator iter = _exp_list->begin(); 
	  iter != _exp_list->end(); ++iter) {
      width += (*iter)->Width();
    }
    return width;
  }

  virtual inline double DoubleValue() {
    cerr << "**Internal Error:" << __FILE__ << ":" << __LINE__
	 << ":try to Call CConcatenation::DoubleValue()." << endl;
    exit(1);
  }

  virtual inline ulonglong Value() {
    string str;
    for (vector<CExpression*>::iterator iter = _exp_list->begin(); 
	 iter != _exp_list->end(); ++iter) {
      str = str + ItoS((*iter)->Value(), (*iter)->Width());
    }
    return StoI(str, 2);
  }
    
  virtual inline CConcatenation* ValueExp() {
    vector<CExpression*> *val_exp_list = new vector<CExpression*>;
    for ( vector<CExpression*>::iterator iter = _exp_list->begin(); 
	  iter != _exp_list->end(); ++iter) {
      val_exp_list->push_back( (*iter)->ValueExp() );
    }
    return new CConcatenation (val_exp_list);
  }

  virtual inline CNumber* Reduce() {
    if ( IsConst() ) {
      return new CNumber (Width(), Value());
    } 
    else {
      return NULL;
    }
  }

  virtual inline void Print(ostream& os=cout) {
    os << "{";
    for (vector<CExpression*>::iterator iter = _exp_list->begin(); 
	 iter != _exp_list->end(); ++iter) {
      (*iter)->Print(os);
      if ( iter != _exp_list->end()-1 ) os << ", ";
    }
    os << "}";
  }
  
  inline void GetSymbol(set<CSymbol*> *st) {
#if 0
    for (vector<CExpression*>::iterator iter = _exp_list->begin(); 
	 iter != _exp_list->end(); ++iter) {
      (*iter)->GetSymbol(st);
    }
#endif
  }

  inline bool HasParam() {
    bool flag = false;
    for (vector<CExpression*>::iterator iter = _exp_list->begin(); 
	 iter != _exp_list->end(); ++iter) {
      flag = flag || (*iter)->HasParam();

      if (flag) return flag;
    }
    return flag;
  }

  inline virtual bool Update(tDirection direction) {
    bool flag = true;
    for (vector<CExpression*>::iterator iter = _exp_list->begin();
	 iter != _exp_list->end(); ++iter) {
      flag = (*iter)->Update(direction) && flag;
    }
    return flag;
  }

  inline bool Update(tType new_type) {
    bool flag = true;
    for (vector<CExpression*>::iterator iter = _exp_list->begin();
	 iter != _exp_list->end(); ++iter) {
      flag = (*iter)->Update(new_type) && flag;
    }
    return flag;
    
  }

  inline virtual void AddRoccure(yy::location loc) {
    for (vector<CExpression*>::iterator iter = _exp_list->begin();
	 iter != _exp_list->end(); ++iter) {
      (*iter)->AddRoccure(loc);
    }
  }
    
  inline virtual void AddLoccure(yy::location loc) {
    for (vector<CExpression*>::iterator iter = _exp_list->begin();
	 iter != _exp_list->end(); ++iter) {
      (*iter)->AddLoccure(loc);
    }
  }

  inline vector<CExpression*> *List() {return _exp_list;}
};

class CDupConcat : public CExpression
{
private: 
  CExpression* _times;
  CConcatenation* _exp_concat;

public: 
  inline CDupConcat(CExpression* times, CConcatenation* exp_concat) :
    _times (times), _exp_concat (exp_concat) {};
  
public:
  inline bool IsConst() {
    return _times->IsConst() && _exp_concat->IsConst();
  }

  inline ulonglong Width() {
    if ( _times->IsConst() ) {
      return _exp_concat->Width() * _times->Value();
    }
    else {
      return _exp_concat->Width() * (Power(2, _times->Width())-1);
    }
  }

  inline double DoubleValue() {
    cerr << "**Internal Error:" << __FILE__ << ":" << __LINE__
	 << ":try to Call CDupConcat::DoubleValue()." << endl;
    exit(1);
  }

  inline ulonglong Value() {
    if ( _times->IsConst() ) {
      CNumber *num = new CNumber(_exp_concat->Width(), _exp_concat->Value());
      string str = num->BinStr(num->Width());
      for ( ulonglong i=1; i<_times->Value(); ++i) {
	str = str + str;
      }
      CNumber *val = new CNumber(str, 2);
      return val->Value();

      delete num;
      delete val;
    }
    else {
      cerr << "**Error:" << __FILE__ << ":" << __LINE__ << ":" 
	   << "Try to get value from non-constant duplicated concatenation.";
      Print(cerr);
      exit(1);
    }
  }

  inline CDupConcat* ValueExp() {
    return new CDupConcat ( _times->ValueExp(), _exp_concat->ValueExp() );
  }

  inline CNumber* Reduce() {
    if ( IsConst() ) {
      return new CNumber (Width(), Value());
    }
    else {
      return NULL;
    }
  }

  inline void Print(ostream& os=cout) {
    os << "{";_times->Print(os);
    _exp_concat->Print(os);
    os << "}";
  }

  inline void GetSymbol(set<CSymbol*> *st) {
#if 0
    _times->GetSymbol(st);
    _exp_concat->GetSymbol(st);
#endif
  }
  
  inline bool HasParam() {
    return
      _times->HasParam() || 
      _exp_concat->HasParam();
  }

  inline virtual bool Update(tDirection direction) {
    bool flag = true;
    flag = _times->Update(direction) && flag;
    flag = _exp_concat->Update(direction) && flag;

    return flag;
  }

  inline virtual bool Update(tType new_type ) {
    bool flag = true;
    flag = _times->Update(new_type) && flag;
    flag = _exp_concat->Update(new_type) && flag;

    return flag;
  }


  inline virtual void AddRoccure(yy::location loc) {
    _times->AddRoccure(loc);
    _exp_concat->AddRoccure(loc);
  }

  inline virtual void AddLoccure(yy::location loc) {
    cerr << "**Internal Error:" << __FILE__ << ":" << __LINE__ 
	 << ":try to set DupConcat expression to LHS." << endl;
    exit(1);
  }

};
  
class CUnaryExp : public CExpression
{
protected: 
  string _operator;
  CExpression* _exp;
  
public:
  inline CUnaryExp(const string &opt, CExpression *exp) : _operator (opt), _exp (exp) {}
  virtual inline bool IsConst() { return _exp->IsConst();}

  virtual inline void Print(ostream&os=cout) {
    os << _operator;
    _exp->Print(os);
  }

  virtual inline ulonglong Width() {};
  virtual inline double    DoubleValue() {return (double) Value();}
  virtual inline ulonglong Value() {};

  virtual inline CExpression* ValueExp() =0;

  virtual inline CNumber* Reduce() {
    if ( this->IsConst() ) {
      return new CNumber(Width(), Value());
    }
    else {
      return NULL;
    }
  }

  virtual inline void GetSymbol(set<CSymbol*> *st) {
#if 0
    _exp->GetSymbol(st);
#endif
  }

  virtual inline bool HasParam() {
    return _exp->HasParam();
  }

  virtual inline bool Update(tDirection direction) {
    return _exp->Update(direction);
  }

  virtual inline void AddRoccure(yy::location loc) {
    _exp->AddRoccure(loc);
  }

  virtual inline void AddLoccure(yy::location loc) {
    cerr << "**Internal Error:" << __FILE__ << ":" << __LINE__
	 << ":try to set unary expression to LHS." << endl;
  }

  virtual inline bool Update(tType new_type) {return true;}

};

class CCondExpNOT : public CUnaryExp
{
public:
  inline CCondExpNOT(CExpression* exp) : CUnaryExp("!", exp) {}

  inline ulonglong Width() {return 1;}
  inline ulonglong Value() {return !_exp->Value();}
  inline CCondExpNOT* ValueExp() {return new CCondExpNOT (_exp->ValueExp());}
};

class CUnaryExpNOT : public CUnaryExp
{
public:
  inline CUnaryExpNOT(CExpression* exp) : CUnaryExp("~", exp) {}

  inline ulonglong Width() {return _exp->Width();}
  inline ulonglong Value() {
    ulonglong val = _exp->Value();
    string str = ItoS(val, _exp->Width());
    for (int i =0; i<str.length(); ++i){
      if ( str[i] == '1' ) 
	str[i] = '0';
      else 
	str[i] = '1';
    }
    return StoI(str, 2);
  }

  inline CUnaryExpNOT* ValueExp() {return new CUnaryExpNOT (_exp->ValueExp());}

};
  

class CUnaryExpAND : public CUnaryExp
{
public : 
  inline CUnaryExpAND(CExpression* exp) : CUnaryExp("&", exp) {}
  
  inline ulonglong Width() {return 1;}
  inline ulonglong Value() {
    string str = ItoS(_exp->Value(), _exp->Width());
    size_t pos = str.find_first_of("0");
    if ( pos == string::npos ) 
      return 1;
    else 
      return 0;
  }
  inline CUnaryExpAND* ValueExp() {return new CUnaryExpAND (_exp->ValueExp());}
};

class CUnaryExpOR : public CUnaryExp
{
public : 
  inline CUnaryExpOR(CExpression* exp) : CUnaryExp("|", exp) {}
  
  inline ulonglong Width() {return 1;}
  inline ulonglong Value() {
    string str = ItoS(_exp->Value(), _exp->Width());
    size_t pos = str.find_first_of("1");
    if ( pos == string::npos ) 
      return 0;
    else 
      return 1;
  }
  inline CUnaryExpOR* ValueExp() {return new CUnaryExpOR (_exp->ValueExp());}
};

class CUnaryExpXOR : public CUnaryExp
{
public : 
  inline CUnaryExpXOR(CExpression* exp) : CUnaryExp("^", exp) {}
  
  inline ulonglong Width() {return 1;}
  inline ulonglong Value() {
    string str = ItoS(_exp->Value(), _exp->Width());
    ulonglong result = 0;
    for (int i=0; i<str.length(); ++i) {
      if (str[i] == '1') 
	result = !result;
    }
    return result;
  }

  inline CUnaryExpXOR* ValueExp() {return new CUnaryExpXOR (_exp->ValueExp());}
};


// ------------------------------
//   CBinaryExp
// ------------------------------
class CBinaryExp : public CExpression
{
protected:
  string _operator;
  CExpression* _exp_a;
  CExpression* _exp_b;

public:
  inline CBinaryExp(const string &opt, CExpression* exp_a, CExpression* exp_b) :
    _operator (opt), _exp_a (exp_a), _exp_b (exp_b) {}


  virtual inline bool IsConst() {return _exp_a->IsConst() && _exp_b->IsConst();}
  virtual inline ulonglong Width() {return Max(_exp_a->Width(), _exp_b->Width());}
  virtual inline void Print(ostream&os=cout) {
    _exp_a->Print(os);
    os << " " << _operator << " ";
    _exp_b->Print(os);
  }
  virtual inline CNumber* Reduce() {
    if ( IsConst() ) {
      return new CNumber (Width(), Value());
    }
    else {
      return NULL;
    }
  }

  virtual ulonglong Value() =0;
  virtual CExpression* ValueExp() =0;

  inline ulonglong CalcMsk(ulonglong width) {
    ulonglong msk = 0;
    for (ulonglong i = 0; i<width; ++i) {
      msk = msk << 1;
      msk += 1;
    }
    return msk;
  }

  virtual inline void GetSymbol(set<CSymbol*> *st) {
#if 0
    _exp_a->GetSymbol(st);
    _exp_b->GetSymbol(st);
#endif
  }

  virtual inline bool HasParam() {
    return 
      _exp_a->HasParam() || 
      _exp_b->HasParam();
  }
  
  virtual inline bool Update(tDirection direction) {
    bool flag = true;
    
    flag = _exp_a->Update(direction) && flag;
    flag = _exp_b->Update(direction) && flag;

    return flag;
  }

  virtual inline void AddRoccure(yy::location loc) {
    _exp_a->AddRoccure(loc);
    _exp_b->AddRoccure(loc);
  }

  virtual inline void AddLoccure(yy::location loc) {
    cerr << "**Internal Error:" << __FILE__ << ":" << __LINE__
	 << ":try to set binary expression to LHS." << endl;
  }

  virtual inline bool Update(tType new_type) {return true;}

};


class CBinExpAND : public CBinaryExp
{
public :
  inline CBinExpAND(CExpression* exp_a, CExpression* exp_b) : 
    CBinaryExp("&", exp_a, exp_b) {}
  
  inline double    DoubleValue() {return (double) Value();}

  inline ulonglong Value() {
    ulonglong val_a = _exp_a->Value();
    ulonglong val_b = _exp_b->Value();
    
    return val_a & val_b;
  }

  inline CBinExpAND* ValueExp() { return new CBinExpAND (_exp_a->ValueExp(), _exp_b->ValueExp());}

};

class CBinExpOR : public CBinaryExp
{
public:
  inline CBinExpOR(CExpression *exp_a, CExpression *exp_b) : 
    CBinaryExp("|", exp_a, exp_b) {}

  inline double    DoubleValue() {return (double) Value();}
  inline ulonglong Value() {
    ulonglong val_a = _exp_a->Value();
    ulonglong val_b = _exp_b->Value();
    
    return val_a | val_b;
  }
  inline CBinExpOR* ValueExp() { return new CBinExpOR (_exp_a->ValueExp(), _exp_b->ValueExp());}
};

class CBinExpXOR : public CBinaryExp
{
public:
  inline CBinExpXOR(CExpression *exp_a, CExpression *exp_b) : 
    CBinaryExp("^", exp_a, exp_b) {}

  inline double    DoubleValue() {return (double) Value();}
  inline ulonglong Value() {
    ulonglong val_a = _exp_a->Value();
    ulonglong val_b = _exp_b->Value();
    
    return val_a ^ val_b;
  }
  inline CBinExpXOR* ValueExp() { return new CBinExpXOR (_exp_a->ValueExp(), _exp_b->ValueExp());}
};


class CBinExpADD : public CBinaryExp
{
public:
  inline CBinExpADD(CExpression *exp_a, CExpression *exp_b) : 
    CBinaryExp("+", exp_a, exp_b) {}

  inline double    DoubleValue() {return _exp_a->DoubleValue() + _exp_b->DoubleValue();}
  inline ulonglong Value() {
    ulonglong val_a = _exp_a->Value();
    ulonglong val_b = _exp_b->Value();
    
    ulonglong val = val_a + val_b;
    
    return val & CalcMsk(Width());
  }
  inline CBinExpADD* ValueExp() { return new CBinExpADD (_exp_a->ValueExp(), _exp_b->ValueExp());}
};


class CBinExpSUB : public CBinaryExp
{
public:
  inline CBinExpSUB(CExpression *exp_a, CExpression *exp_b) : 
    CBinaryExp("-", exp_a, exp_b) {}

  inline double    DoubleValue() {return _exp_a->DoubleValue() - _exp_b->DoubleValue();}
  inline ulonglong Value() {
    ulonglong val_a = _exp_a->Value();
    ulonglong val_b = _exp_b->Value();
    ulonglong val = val_a - val_b;
    
    return val & CalcMsk(Width());
  }
  inline CBinExpSUB* ValueExp() { return new CBinExpSUB (_exp_a->ValueExp(), _exp_b->ValueExp());}
};


class CBinExpMUL : public CBinaryExp
{
public:
  inline CBinExpMUL(CExpression *exp_a, CExpression *exp_b) : 
    CBinaryExp("*", exp_a, exp_b) {}

  inline double    DoubleValue() {return _exp_a->DoubleValue() * _exp_b->DoubleValue();}
  inline ulonglong Width() {return _exp_a->Width() + _exp_b->Width();}
  inline ulonglong Value() {
    ulonglong val_a = _exp_a->Value();
    ulonglong val_b = _exp_b->Value();
    ulonglong val = val_a * val_b;
    
    return val & CalcMsk(Width());
  }
  inline CBinExpMUL* ValueExp() { return new CBinExpMUL (_exp_a->ValueExp(), _exp_b->ValueExp());}
};

class CBinExpDIV : public CBinaryExp
{
public:
  inline CBinExpDIV(CExpression *exp_a, CExpression *exp_b) : 
    CBinaryExp("/", exp_a, exp_b) {}

  inline double    DoubleValue() {return _exp_a->DoubleValue() / _exp_b->DoubleValue();}
  inline ulonglong Value() {
    ulonglong val_a = _exp_a->Value();
    ulonglong val_b = _exp_b->Value();
    ulonglong val = val_a / val_b;
    
    return val;
  }
  inline CBinExpDIV* ValueExp() { return new CBinExpDIV (_exp_a->ValueExp(), _exp_b->ValueExp());}
};


class CBinExpMOD : public CBinaryExp
{
public:
  inline CBinExpMOD(CExpression *exp_a, CExpression *exp_b) : 
    CBinaryExp("%", exp_a, exp_b) {}

  inline double    DoubleValue() {return (double) Value();}
  inline ulonglong Value() {
    ulonglong val_a = _exp_a->Value();
    ulonglong val_b = _exp_b->Value();
    ulonglong val = val_a % val_b;
    
    return val;
  }
  inline CBinExpMOD* ValueExp() { return new CBinExpMOD (_exp_a->ValueExp(), _exp_b->ValueExp());}
};

class CBinExpRSHFT : public CBinaryExp
{
public:
  inline CBinExpRSHFT(CExpression *exp_a, CExpression *exp_b) : 
    CBinaryExp(">>", exp_a, exp_b) {}

  inline double    DoubleValue() {return (double) Value();}
  inline ulonglong Value() {
    ulonglong val_a = _exp_a->Value();
    ulonglong val_b = _exp_b->Value();
    ulonglong val = val_a >> val_b;
    
    return val;
  }
  inline CBinExpRSHFT* ValueExp() { return new CBinExpRSHFT (_exp_a->ValueExp(), _exp_b->ValueExp());}
};


class CBinExpLSHFT : public CBinaryExp
{
public:
  inline CBinExpLSHFT(CExpression *exp_a, CExpression *exp_b) : 
    CBinaryExp("<<", exp_a, exp_b) {}

  inline double    DoubleValue() {return (double) Value();}
  inline ulonglong Value() {
    ulonglong val_a = _exp_a->Value();
    ulonglong val_b = _exp_b->Value();
    ulonglong val = val_a << val_b;
    
    return val;
  }
  inline CBinExpLSHFT* ValueExp() { return new CBinExpLSHFT (_exp_a->ValueExp(), _exp_b->ValueExp());}
};


// ------------------------------
//   CBinaryCondExp
// ------------------------------
class CBinaryCondExp : public CBinaryExp 
{
public: 
  inline CBinaryCondExp(const string &opt, CExpression *exp_a, CExpression *exp_b) : 
    CBinaryExp(opt, exp_a, exp_b) {}

  inline ulonglong Width() {return 1;}
  inline CNumber* Reduce() {
    if ( IsConst() ) {
      return new CNumber (1, Value());
    }
    else {
      return NULL;
    }
  }

  virtual double    DoubleValue()=0;
  virtual ulonglong Value() =0;
  virtual CExpression* ValueExp() =0;

};

#define BIN_COND_EXP_DECLARE(name, operator)				\
  class name : public CBinaryCondExp					\
  {									\
  public:								\
    inline name(CExpression *exp_a, CExpression *exp_b) :		\
      CBinaryCondExp(#operator, exp_a, exp_b) {}			\
									\
    inline double    DoubleValue() {return (double) Value();}		\
    inline ulonglong Value() {return _exp_a->Value() operator _exp_b->Value() ? 1 : 0;} \
    inline name* ValueExp() {return new name (_exp_a->ValueExp(), _exp_b->ValueExp());} \
  }
  
BIN_COND_EXP_DECLARE(CCondExpAND, &&);
// class CCondExpAND : public CBinaryCondExp
// {
// public:
//   inline CCondExpAND(CExpression *exp_a, CExpression *exp_b) : 
//     CBinaryCondExp("&&", exp_a, exp_b) {}

//   inline ulonglong Value() {return _exp_a->Value() && _exp_b->Value() ? 1 : 0;}
//   inline CExpression* ValueExp() {return new CCondExpAND (_exp_a->ValueExp(), _exp_b->ValueExp());}
// };

BIN_COND_EXP_DECLARE(CCondExpOR, ||);
// class CCondExpOR : public CBinaryCondExp
// {
// public:
//   inline CCondExpOR(CExpression *exp_a, CExpression *exp_b) : 
//     CBinaryCondExp("||", exp_a, exp_b) {}

//   inline ulonglong Value() {return _exp_a->Value() || _exp_b->Value() ? 1 : 0;}
//   inline CExpression* ValueExp() {return new CCondExpOR (_exp_a->ValueExp(), _exp_b->ValueExp());}
// };


BIN_COND_EXP_DECLARE(CCondExpGT, >);
// class CCondExpGT : public CBinaryCondExp
// {
// public:
//   inline CCondExpGT(CExpression *exp_a, CExpression *exp_b) : 
//     CBinaryCondExp(">", exp_a, exp_b) {}

//   inline ulonglong Value() {return _exp_a->Value() > _exp_b->Value() ? 1 : 0;}
//   inline CExpression* ValueExp() {return new CCondExpGT (_exp_a->ValueExp(), _exp_b->ValueExp());}
// };

BIN_COND_EXP_DECLARE(CCondExpLT, <);
// class CCondExpLT : public CBinaryCondExp
// {
// public:
//   inline CCondExpLT(CExpression *exp_a, CExpression *exp_b) : 
//     CBinaryCondExp("<", exp_a, exp_b) {}

//   inline ulonglong Value() {return _exp_a->Value() < _exp_b->Value() ? 1 : 0;}
//   inline CExpression* ValueExp() {return new CCondExpLT (_exp_a->ValueExp(), _exp_b->ValueExp());}
// };

BIN_COND_EXP_DECLARE(CCondExpGE, >=);
// class CCondExpGE : public CBinaryCondExp
// {
// public:
//   inline CCondExpGE(CExpression *exp_a, CExpression *exp_b) : 
//     CBinaryCondExp(">=", exp_a, exp_b) {}

//   inline ulonglong Value() {return _exp_a->Value() >= _exp_b->Value() ? 1 : 0;}
//   inline CExpression* ValueExp() {return new CCondExpGE (_exp_a->ValueExp(), _exp_b->ValueExp());}
// };

BIN_COND_EXP_DECLARE(CCondExpLE, <=);
// class CCondExpLE : public CBinaryCondExp
// {
// public:
//   inline CCondExpLE(CExpression *exp_a, CExpression *exp_b) : 
//     CBinaryCondExp("<=", exp_a, exp_b) {}

//   inline ulonglong Value() {return _exp_a->Value() <= _exp_b->Value() ? 1 : 0;}
//   inline CExpression* ValueExp() {return new CCondExpLE (_exp_a->ValueExp(), _exp_b->ValueExp());}
// };


BIN_COND_EXP_DECLARE(CCondExpNE, !=);
// class CCondExpNE : public CBinaryCondExp
// {
// public:
//   inline CCondExpNE(CExpression *exp_a, CExpression *exp_b) : 
//     CBinaryCondExp("!=", exp_a, exp_b) {}

//   inline ulonglong Value() {return _exp_a->Value() != _exp_b->Value() ? 1 : 0;}
//   inline CExpression* ValueExp() {return new CCondExpNE (_exp_a->ValueExp(), _exp_b->ValueExp());}  
// };

BIN_COND_EXP_DECLARE(CCondExpEQ, ==);
// class CCondExpEQ : public CBinaryCondExp
// {
// public:
//   inline CCondExpEQ(CExpression *exp_a, CExpression *exp_b) : 
//     CBinaryCondExp("==", exp_a, exp_b) {}

//   inline ulonglong Value() {return _exp_a->Value() == _exp_b->Value() ? 1 : 0;}
//   inline CExpression* ValueExp() {return new CCondExpEQ (_exp_a->ValueExp(), _exp_b->ValueExp());}
// };


#endif
