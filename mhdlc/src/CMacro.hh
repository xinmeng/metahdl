#ifndef __CMACRO_HH__
#define __CMACRO_HH__

#include <sstream>
#include <string>
#include <vector>
#include "ExpressionBase.hh"
using namespace std;

// ------------------------------
//   CMacroBody
// ------------------------------
class CMacroBody
{
public:
  virtual string Expand(const vector<CExpression*> &arg_values)=0;
};

class CMacroBodyLiteral : public CMacroBody
{
private:
  string _literal;

public:
  inline CMacroBodyLiteral(const string &literal) : _literal (literal) {}
  inline virtual string Expand(const vector<CExpression*> &arg_values) {return _literal;}
};


class CMacroBodyArgRef : public CMacroBody
{
private:
  ulonglong _arg_index;

public:
  inline CMacroBodyArgRef(const ulonglong &index) : _arg_index (index) {}
  inline virtual string Expand(const vector<CExpression*> &arg_values) {
    ostringstream sstr;
    arg_values[_arg_index]->Print(sstr);
    return sstr.str();
  }
};


class CMacroBodyStringfication : public CMacroBody
{
private:
  ulonglong _arg_index;

public:
  inline CMacroBodyStringfication(const ulonglong &index) : _arg_index (index) {}
  inline virtual string Expand(const vector<CExpression*> &arg_values) {
    ostringstream sstr;
    sstr << "\"";
    arg_values[_arg_index]->Print(sstr);
    sstr << "\"";

    return sstr.str();    
  }
};



class CMacroBodyOptArgRef : public CMacroBody
{
private:
  ulonglong _opt_arg_index;
  
public:
  inline CMacroBodyOptArgRef(const ulonglong &index ) : _opt_arg_index (index) {}
  inline virtual string Expand(const vector<CExpression*> &arg_values){
    if (_opt_arg_index > arg_values.size()-1) {
      return "";
    }
    else {
      ostringstream sstr;
      for (int i=_opt_arg_index;i<arg_values.size();i++) {
	arg_values[i]->Print(sstr);
	if (i!=arg_values.size()-1) 
	  sstr << ", ";
      }
    
      return sstr.str();
    }
  }
};


class CMacroBodyOptComma : public CMacroBody
{
private:
  ulonglong _opt_arg_index;

public:
  inline CMacroBodyOptComma(const ulonglong &index) : _opt_arg_index (index) {}
  inline virtual string Expand(const vector<CExpression*> &arg_values) {
    if (_opt_arg_index > arg_values.size() -1) 
      return "";
    else 
      return ", ";
  }
};


// ------------------------------
//   CMacro
// ------------------------------
class CMacro
{
protected:
  string _name;

public:
  inline CMacro(const string &name) : _name (name) {}
  
  virtual string Expand()=0;
  virtual string Expand(const vector<CExpression*> &arg_vlaues)=0;
};


class CObjMacro : public CMacro
{
private:
  string _body;
  
public:
  inline CObjMacro(const string &name) : 
    CMacro(name), _body ("") {}

  inline CObjMacro(const string &name, const string &body) : 
    CMacro(name), _body(body) {}

  inline virtual string Expand() {return _body;}
  inline virtual string Expand(const vector<CExpression*> &arg_vlaues) {return Expand();}
};


class CArithMacro : public CExpression, public CMacro
{
private:
  CExpression *_value;

public:
  inline CArithMacro(const string &name, CExpression *value) :
    CMacro(name), _value (value) {}

  inline virtual void Print(ostream &os=cout) {_value->Print(os);}
  inline virtual CExpression* Reduce() {return _value->Reduce();}
  
  inline void SetValue(CExpression *value) {_value = value;}

  inline virtual string Expand() {
    ostringstream sstr;
    _value->Print(sstr);
    return sstr.str();
  }

  inline virtual string Expand(const vector<string> &arg_values) {return Expand();}
};




class CFuncMacro : public CMacro
{
protected:
  vector<string> *_arg_names;
  vector<CMacroBody*> *_body;


public:
  inline CFuncMacro(const string &name, 
		    vector<string> *arg_names, 
		    vector<CMacroBody*> *body) :
    CMacro(name), _arg_names (arg_names), _body (body) {}

  inline virtual string Expand() {
    ostringstream sstr;
    sstr << "Internal Error:Try to expand CFuncMacro \"" 
	 << _name << "\" without arguments." << endl;

    throw sstr.str();
  }

  inline virtual string Expand(const vector<CExpression*> &arg_values) {
    if (_arg_names->size() != arg_values.size()) {
      ostringstream sstr;
      sstr << "Internal Error: Macro \"" << _name << "\" requires " << _arg_names->size() 
	   << " arguments, but called with " << arg_values.size() << " arguments." << endl;

      throw sstr.str();
    }
    else {
      string str;
      for (vector<CMacroBody*>::iterator iter=_body->begin(); 
	   iter != _body->end(); iter++) {
	str += (*iter)->Expand(arg_values); 
      }
      
      return str;
    }
  }
};


class CVariadicMacro : public CFuncMacro
{
private:
  string _opt_arg_name;

public:
  inline CVariadicMacro(const string &name, 
			vector<string> *arg_names,
			vector<CMacroBody*> *body, 
			const string &opt_arg_name="__VA_ARG__") : 
    CFuncMacro(name, arg_names, body), _opt_arg_name (opt_arg_name) {}

  inline virtual string Expand() {
    if (_arg_names->size()==0) {
      vector<CExpression*> arg_values; // produce an empty arg value list

      return Expand(arg_values);
    }
    else {
      ostringstream sstr;
      sstr << "Internal Error: Macro \"" << _name << "\" requires at least " << _arg_names->size()
	   << " arguments, but called with no arguments." << endl;
      
      throw sstr.str();
    }
  }
  

  inline virtual string Expand(const vector<CExpression*> &arg_values) {
    if (_arg_names->size() > arg_values.size()) {
      ostringstream sstr;
      sstr << "Internal Error: Macro \"" << _name << "\" requires at least " << _arg_names->size()
	   << " arguments, but called with " << arg_values.size() << " arguments." << endl;
      throw sstr.str();
    }
    else {
      string str = "";
      for (vector<CMacroBody*>::iterator iter=_body->begin(); 
	   iter != _body->end(); iter++) 
	str += (*iter)->Expand(arg_values);

      return str;
    }
  }

};

inline ulonglong
MppBuildInFunc(const string & func_name, vector<CExpression*> *arg_values)
{
  return 0;
}


#endif
