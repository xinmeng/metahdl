#ifndef __TABLE_HH__
#define __TABLE_HH__

#include "Mfunc.hh"
#include "Expression.hh"
#include "CodeBlock.hh"

enum tXXFix {PREFIX, SUFFIX};

class CIOTab
{
private:
  map<string, CSymbol*> _port;
  map<string, CExpression*> _connect_map;

public:
  inline CSymbol* Exist(const string &name) {
    if ( _port.count(name) > 0 ) {
      return _port[name];
    }
    else {
      return NULL;
    }
  }

  inline void Insert(CSymbol* symbol) {
    _port[symbol->name] = symbol;
    //_connect_map[symbol->name] = symbol->name;
  }
  
  inline CSymbol* Connect(const string & port_name, CExpression *net_exp) {
    if ( _connect_map.count(port_name) > 0 ) {
       _connect_map[port_name] = net_exp;
       return _port[port_name];
    }
    else {
      return NULL;
    }
  }

  inline vector<string> SplitRegexSub(const string & cmd, char delim) {
      vector<string> tokens;
      size_t pos=0;
      size_t pos_nxt;

      while ((pos_nxt=cmd.find(delim, pos)) != string::npos) {
          tokens.push_back(cmd.substr(pos, pos_nxt-pos));
          pos = pos_nxt+1;
      }

      if (tokens[0] != "s" || tokens[1] == "" || tokens.size() < 3) {
          cerr << "\033[00;31m\n**"
               << "Error:Bad regex:"
               << cmd << "\033[00m" << endl;
          exit(1);                    
      }

      // if (pos != cmd.length()) {
      //     // if pos_nxt reaches end, pos=pos_nxt+1 make pos go beyond
      //     // string end
      //     tokens.push_back(cmd.substr(pos));
      //     cerr << "\033[00;35m\n**"
      //          << "Warning:incomplete regex: missing trailing \"/\": "
      //          << cmd << "\033[00m" << endl;
      // }

      return tokens;
  }

  inline void Connect(const string & regexp) {
      vector<string> tokens = this->SplitRegexSub(regexp, '/');
      regex conn_rule (tokens[1]);

      for (map<string, CExpression*>::iterator iter = _connect_map.begin(); 
           iter != _connect_map.end(); ++iter) {
          if ( iter->second && typeid( *(iter->second) ) == typeid( CVariable ) ) {
              CVariable *var = dynamic_cast<CVariable*> (iter->second);
              CSymbol *tmp_symb = var->Symb();
              tmp_symb->name = regex_replace(tmp_symb->name,
                                             conn_rule, tokens[2],
                                             regex_constants::match_not_null);
              tmp_symb->name = ConvertCase(tmp_symb->name);

              CExpression *exp;
              if (regex_match(tmp_symb->name, regex_empty_net) ) {
                  iter->second = NULL; // _connect_map[iter->first] = NULL;
              }
              else if (regex_match(tmp_symb->name, regex_dec_num)) {
                  exp = new CBasedNum(tmp_symb->name, 10);
                  iter->second = exp; // _connect_map[iter->first] = exp;
              }
              else if (regex_match(tmp_symb->name, regex_hex_num)) {
                  exp = new CBasedNum(tmp_symb->name, 16);
                  iter->second = exp; // _connect_map[iter->first] = exp;
              }
              else if (regex_match(tmp_symb->name, regex_bin_num)) {
                  exp = new CBasedNum(tmp_symb->name, 2);
                  iter->second = exp; // _connect_map[iter->first] = exp;
              }
              else if (regex_match(tmp_symb->name, regex_int_num)) {
                  exp = new CNumber(tmp_symb->name);
                  iter->second = exp; // _connect_map[iter->first] = exp;
              }
          }
      }
  }
      

  // inline void Connect(const string & regexp) {
  //   for (map<string, CExpression*>::iterator iter = _connect_map.begin(); 
  //        iter != _connect_map.end(); ++iter) {
  //     if ( iter->second && typeid( *(iter->second) ) == typeid( CVariable ) ) {
  //       CVariable *var = dynamic_cast<CVariable*> (iter->second);
  //       CSymbol *tmp_symb = var->Symb();
  //       tmp_symb->name = regexp_substitute(tmp_symb->name, regexp);
	
  //       CExpression *exp;
  //       if (regexp_match(tmp_symb->name, "/^$/") ) {
  //         iter->second = NULL; // _connect_map[iter->first] = NULL;
  //       }
  //       else if (regexp_match(tmp_symb->name, "/^([0-9]+)?'[dD][0-9_]+$/")) {
  //         exp = new CBasedNum(tmp_symb->name, 10);
  //         iter->second = exp; // _connect_map[iter->first] = exp;
  //       }
  //       else if (regexp_match(tmp_symb->name, "/^([0-9]+)?'[hH][0-9a-fA-F_]+$/")) {
  //         exp = new CBasedNum(tmp_symb->name, 16);
  //         iter->second = exp; // _connect_map[iter->first] = exp;
  //       }
  //       else if (regexp_match(tmp_symb->name, "/^([0-9]+)?'[bB][01_]+$/")) {
  //         exp = new CBasedNum(tmp_symb->name, 2);
  //         iter->second = exp; // _connect_map[iter->first] = exp;
  //       }
  //       else if (regexp_match(tmp_symb->name, "/^[0-9_]+$/")) {
  //         exp = new CNumber(tmp_symb->name);
  //         iter->second = exp; // _connect_map[iter->first] = exp;
  //       }
  //     }
  //   }
  // }

  inline void Connect(tXXFix xxfix, const string &str) {
    for (map<string, CExpression*>::iterator iter = _connect_map.begin() ;
	 iter != _connect_map.end(); ++iter) {
      if ( iter->second && typeid( *(iter->second) ) == typeid( CVariable ) ) {
	CVariable *var = dynamic_cast<CVariable*> (iter->second);
	CSymbol *tmp_symb = var->Symb();

	if (xxfix == PREFIX ) {
	  tmp_symb->name = str + tmp_symb->name;
	}
	else {
	  tmp_symb->name = tmp_symb->name + str;
	}
      }
    }
  }

  inline map<CSymbol*, CExpression*, CCompareConnection> * GetIO() {
    map<CSymbol*, CExpression*, CCompareConnection> *io = new map<CSymbol*, CExpression*, CCompareConnection>;
    for (map<string, CExpression*>::iterator iter = _connect_map.begin();
	 iter != _connect_map.end(); ++iter) {
       CSymbol *symbol;
       CExpression *exp; 
      
       if ( iter->second ) {
	  if ( typeid( *(iter->second) ) == typeid( CVariable ) ) {
	     CVariable *var = dynamic_cast<CVariable*> (iter->second);
	     CSymbol *var_symb = var->Symb();
	     symbol = new CSymbol(var_symb->name);
	     if ( var->Msb() ) {
		symbol->Update( var->Msb()->ValueExp() );
	     }
	     else {
		symbol->Update( _port[iter->first]->msb->ValueExp() );
	     }
// 	     if ( var_symb->msb == CONST_NUM_0 ) {
// 		symbol->Update( _port[iter->first]->msb->ValueExp() );
// 	     }
// 	     else {
// 		symbol->Update( var_symb->msb->ValueExp() );
// 	     }

	     symbol->Update( _port[iter->first]->direction );
	     symbol->reference = _port[iter->first];
             // here is a potential problem, if port is 2D,
             // and variable should be LARGER than 2D.
             // Need further revise.
             if (_port[iter->first]->is_2D) {
                 symbol->is_2D = _port[iter->first]->is_2D;
                 symbol->length_msb = _port[iter->first]->length_msb;
             }
             else if (var_symb->is_2D) {
                 symbol->is_2D = var_symb->is_2D;
                 symbol->length_msb = var_symb->length_msb;
             }

             if (symbol->is_2D)
                 exp = new CVariable(symbol, var->Addr(), var->Msb(), var->Lsb());
             else 
                 exp = new CVariable(symbol, var->Msb(), var->Lsb());

	     if ( var_symb == _port[iter->first] ) 
		delete var_symb;

	  }
	  else {
	     exp = iter->second;
	  }
       }
       else {
	  exp = iter->second;
       }

       (*io)[_port[iter->first]] = exp;
    }
    return io;
  }

  inline void Reset() {
    CSymbol *symbol;
    for (map<string, CSymbol*>::iterator iter = _port.begin();
	 iter != _port.end(); ++iter) {
      symbol = new CSymbol( iter->second->name, 
        		    iter->second->msb,
        		    iter->second->direction,
        		    iter->second );

      _connect_map[iter->first] = new CVariable (symbol);
        // if (iter->second->is_2D)
        //     _connect_map[iter->first] = new CVariable (symbol/*, 
        //                                                symbol->length_msb, 
        //                                                symbol->msb, 
        //                                                symbol->lsb*/ );
        // else
        //     _connect_map[iter->first] = new CVariable (symbol/*, 
        //                                                symbol->msb, 
        //                                                symbol->lsb*/ );

    }
  }

  inline void PrintName(ostream &os=cout) {
    os << endl;
    for ( map<string, CSymbol*>::iterator iter = _port.begin();
	  iter != _port.end(); ++iter) {
      os << "  " << iter->first;
      if ( ++iter != _port.end() ) {
	--iter;
	os << ", " << endl;
      }
      else {
	--iter;
      }
    }
  }

  inline void PrintPort(ostream &os=cout) {
    for ( map<string, CSymbol*>::iterator iter = _port.begin();
	  iter != _port.end(); ++iter) {
      iter->second->PrintPort(os);
    }
  }


  inline string & ChkMissingPort() {
    string *msg = new string;

    for (map<string, CSymbol*>::iterator iter = _port.begin();
	 iter != _port.end(); ++iter) {
        if (iter->second->force_port) {
            if (iter->second->direction == INPUT && iter->second->roccur.size()) {
                (*msg) = (*msg) + " force input port \"" + iter->second->name + "\" should not be used as RHV\n";
            }
            else if (iter->second->direction == OUTPUT && iter->second->loccur.size()) {
                (*msg) = (*msg) + " force output port \"" + iter->second->name + "\" should not be used as LHV\n";
            }
            else if (iter->second->direction == INOUT && (iter->second->roccur.size() || iter->second->loccur.size())) {
                (*msg) = (*msg) + " force inout port \"" + iter->second->name + "\" should not be used as LHV nor RHV\n";
            }
        }
        else {
            if ( iter->second->direction == INPUT ) {
                if ( iter->second->roccur.size() == 0 ) {
                    (*msg) = (*msg) + "  missing input \"" + iter->second->name + "\"\n"; //  has no load.\n";
                }
            }
            else if ( iter->second->direction == OUTPUT ) {
                if ( iter->second->loccur.size() == 0 ) {
                    (*msg) = (*msg) + "  missing output \"" + iter->second->name + "\"\n"; //  has no driver.\n";
                }
            }
            else if ( iter->second->direction == INOUT ) {
                if ( iter->second->roccur.size() == 0 ) {
                    (*msg) = (*msg) + "  missing load for inout \"" + iter->second->name + "\"\n"; //  has no load.\n";
                }
                if ( iter->second->loccur.size() == 0 ) {
                    (*msg) = (*msg) + "  missing driver for inout \"" + iter->second->name + "\"\n"; //  has no driver.\n";
                }
            }
        }
    }
    return (*msg);
  }


};

class CSymbolTab
{
private:
  map<string, CSymbol*> _symbols;

public:
  inline CSymbol* Exist(const string & name) {
    if (_symbols.count(name) > 0 )  
      return _symbols[name];
    else 
      return NULL;
  }

  inline bool Remove( const string &name) {
    if ( _symbols.count(name) > 0 ) {
      _symbols.erase(name);
      return true;
    }
    else {
      return false;
    }
  }

  inline CSymbol* Insert(const string & name) {
    if ( _symbols.count(name) > 0 ) {
      return _symbols[name];
    }
    else {
      CSymbol* symbol = new CSymbol (name);
      _symbols[name] = symbol;
      return symbol;
    }
  }

  inline bool UpdateSymbol(const string & name, CExpression* msb) {
    if (_symbols[name]->width_fixed ) {
      return false;
    }
    else {
      _symbols[name]->msb = msb;
      return true;
    }
  }

  inline bool UpdateSymbol(const string & name, tType type) {
    _symbols[name]->type = type; return true;
  }

  inline bool UpdateSymbol(const string & name, tDirection direction) {
    if ( _symbols[name]->io_fixed || 
	 _symbols[name]->is_const ) {
      return false;
    }
    else {
      if ( _symbols[name]->direction != NONPORT && 
	   _symbols[name]->direction != direction ) {
	_symbols[name]->direction = NONPORT;
      }
      else {
	_symbols[name]->direction = direction;
      }
      return true;
    }
  }

  inline string& ExtractIO(CIOTab* IOTable) {
    string *msg = new string;

    for (map<string, CSymbol*>::iterator iter = _symbols.begin();
	 iter != _symbols.end(); ++iter) {
      switch ( (*iter).second->direction ) {
      case INPUT: 
	if ( !IOTable->Exist(iter->first) ) {
	  (*msg) = (*msg) + "  new input \"" + iter->first + "\"\n";
	  IOTable->Insert( (*iter).second );
	}
	break;

      case OUTPUT: 
	if ( !IOTable->Exist(iter->first) ) {
	  (*msg) = (*msg) + "  new output \"" + iter->first + "\"\n";
	  IOTable->Insert( (*iter).second );
	}

      case INOUT:
	if ( !IOTable->Exist(iter->first) ) {
	  (*msg) = (*msg) + "  new inout \"" + iter->first + "\"\n";
	  IOTable->Insert( (*iter).second );
	}
      }
    }
    IOTable->Reset();
    return (*msg);
  }

  inline void PrintDeclare(ostream &os=cout) {
    for (map<string, CSymbol*>::iterator iter = _symbols.begin();
	 iter != _symbols.end(); ++iter) {
      iter->second->PrintDeclare(os);
    }
  }

#if 0
  inline string& ChkMultiDriver() {
    ostringstream buf;
    string *msg = new string;

    for ( map<string, CSymbol*>::iterator iter = _symbols.begin(); 
	  iter != _symbols.end(); ++iter) {
      if ( iter->second->driver.size() > 1 ) {
	buf << "  Multi-driver on Net \"" << iter->first << "\":" << endl;
	for ( vector<CCodeBlock*>::iterator viter = iter->second->driver.begin();
	      viter != iter->second->driver.end(); ++viter) {
	  buf << "     Driven by: " << (*viter)->Loc() << endl;
	}
	buf << endl;
      }
    }

    (*msg) = (*msg) + buf.str();
    return (*msg);
  }
#endif

};

class CParamTab
{
private:
  map<string, CParameter*> _param;
  vector<string>           _order;

public:
  inline CParameter* Exist(const string &name) {
    if ( _param.count(name) > 0 ) 
      return _param[name];
    else
      return NULL;
  }

  inline void Insert(CParameter* parameter) {
    _param[parameter->Name()] = parameter;
    _order.push_back(parameter->Name());
  }

  inline bool SetParam(const string &name, CExpression* value) {
    if ( _param.count(name) > 0 ) {
      return _param[name]->SetValue(value);
    }
    else {
      return false;
    }
  }

  inline bool SetParam(vector<CExpression*> *param_list) {
    for ( int i = 0; i< param_list->size(); ++i ) {
      if (i > _order.size() - 1 ) {
	return false;
      }
      else {
	if (!_param[_order[i]]->SetValue( (*param_list)[i])) {
	  return false;
	}
      }
    }

    return true;

//     if ( param_list->size() != _order.size() ) {
//       for ( int i = 0; i< param_list->size(); ++i ) {
// 	_param[_order[i]]->SetValue( (*param_list)[i]);
//       }
//       return false;
//     }
//     else {
//       for ( int i = 0; i< _order.size(); ++i ) {
// 	_param[_order[i]]->SetValue( (*param_list)[i]);
//       }
//       return true;
//     }
  }

  inline vector<pair<string, CExpression*> >* GetParam() {
    vector<pair<string, CExpression*> > *param_list = new vector<pair<string, CExpression*> >;
    for ( int i=0; i<_order.size(); ++i) {
      // param_list->push_back( pair<string, CExpression*>(_order[i],  _param[_order[i]]->ValueExp() ) );
      if (_param[_order[i]]->global && _param[_order[i]]->Override()) {
	param_list->push_back( pair<string, CExpression*>(_order[i],  _param[_order[i]]->ValueExp() ) );
      }
    }
    return param_list;
  }

  inline void Reset() {
    for ( map<string, CParameter*>::iterator iter = _param.begin();
	  iter != _param.end(); ++iter) {
      iter->second->SetValue(NULL);
    }
  }

  inline void Print(ostream &os=cout) {
    for (int i=0; i<_order.size(); ++i) {
        if (_param[_order[i]]->global) 
            os << "parameter ";
        else 
            os << "localparam ";
        os << _order[i] << " = ";
        _param[_order[i]]->DefinitionExp()->Print(os);
        os << ";" << endl;
    }
  }

};


class CModule
{
public:
  yy::location loc;
  string name;
  CIOTab* io_table;
  CParamTab* param_table;

public:
  inline CModule(const yy::location &loc_, const string &name_, CIOTab* io_table_, CParamTab* param_table_) : 
    loc (loc_), name (name_), io_table (io_table_), param_table (param_table_) {}

  virtual void Print(ostream& os) = 0;
  
};


class CModMHDL : public CModule
{
public:
  vector<CCodeBlock*> *code_blocks;
  CSymbolTab          *symbol_table;

public:
  inline CModMHDL(const yy::location &loc_, const string &name_, CIOTab* io_table_, CParamTab* param_table_, 
		  vector<CCodeBlock*> *code_blocks_, CSymbolTab *symbol_table_) : 
    CModule(loc_, name_, io_table_, param_table_), code_blocks (code_blocks_), symbol_table (symbol_table_) {}

  inline void Print(ostream& os=cout) {
    // module declaration
    os << "module " << name << " (";
    io_table->PrintName(os);
    os << ");" << endl << endl;
    
    // parameters
    param_table->Print(os);
    os << endl;

    // Ports
    io_table->PrintPort(os);
    os << endl;

    // symbols
    symbol_table->PrintDeclare(os);
    os << endl;

    // codes
    for ( vector<CCodeBlock*>::iterator iter = code_blocks->begin(); 
	  iter != code_blocks->end(); ++iter) {
      (*iter)->Print(os);
      os << endl;
    }

    // endmodule
    os << "endmodule" << endl;
  }
};

class CModSV : public CModule
{
public :
  inline CModSV(const yy::location &loc_, const string &name_, CIOTab *io_table_, CParamTab* param_table_) : 
    CModule(loc_, name_, io_table_, param_table_) {}

  void Print(ostream&os=cout) {}
};


class CModTab
{
private:
  map<string, CModule*> _mods;

public:
  inline CModTab() {}

  inline CModule*  Exist(const string &name) {
    if ( _mods.count(name) > 0 ) {
      return _mods[name]; 
    }
    else {
      return NULL;
    }
  }

  inline void Insert(CModule* mod) {_mods[mod->name] = mod;}

  inline void Print(ostream&os) {
    for (map<string, CModule*>::iterator iter = _mods.begin();
	 iter != _mods.end(); ++iter) {
      os << iter->first << " " << iter->second->loc << endl;
    }
  }

  inline int Size() {return _mods.size();}
};


#endif
