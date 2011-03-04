#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#include <sstream>
#include <iomanip>

#include "Mfunc.hh"

#include <EXTERN.h>
#include <perl.h>

// vpp.l 
extern int output_line_directive;
extern int output_ifdef_directive;


extern int mhdl_flex_debug; 
extern int sv_flex_debug;


// proto.h
void store_define(char *def_text);


// global option variables
int DebugPPLexer = 0;
int DebugMHDLLexer  = 0;
int DebugMHDLParser = 0;
int DebugSVLexer  = 0;
int DebugSVParser = 0;
bool FastDependParse = false;
bool CopyVerilogCode = false;
bool LEGACY_VERILOG_MODE = false;
bool OutputCodeLocation = false;

string command = "";
vector<string> files;
list<string>   paths;
string workdir = "workdir";
string mhdlversion = "1.2.1";


int IsDir(const char *s)
{
  struct stat f;
  
  if ( !stat(s, &f) && S_ISDIR(f.st_mode) ) 
    return 1;
  else 
    return 0;
}

int IsFile(const char *s)
{
  struct stat f;
  
  if ( !stat(s, &f) && S_ISREG(f.st_mode) )
    return 1;
  else 
    return 0;
}


char *
SearchFile(const string &name)
{
  return SearchFile(name.c_str());
}

char *
SearchFile(const char *name)
{
  char *path;
  string s;

  /* absolut path */
  if ( name[0] == '/' ) {
    if ( IsFile(name) ) {
      path = (char *)calloc(1, strlen(name)+1);
      strcpy(path, name);
      return path;
    }
    else 
      return NULL;
  }
  /* relative path */
  else {
    for ( list<string>::iterator iter = paths.begin(); 
	  iter != paths.end(); ++iter ) {
      string tmp = *iter;
      s = (*iter);
      if ( s[s.length()-1] == '/' ) {
	s = s + name;
      }
      else {
	s = s + "/" + name;
      }
      
      if ( IsFile( s.c_str() ) ) {
	path = (char *)calloc(1, s.length()+1);
	strcpy(path, s.c_str() );

	paths.erase(iter);
	paths.push_front(tmp);

	return path;
      }
    }
    return NULL;
  }
}


void
GetOpt(int argc, char *argv[])
{
  int i, arglen;
  string s;
  char *cstr;

  /* Default to old behavior. */
  output_line_directive = 1;
  output_ifdef_directive = 0;

  /* Default lexer debug option*/
  mhdl_flex_debug = 0; 
  sv_flex_debug = 0;

  /* initialization  */
  paths.push_back(getenv("PWD"));


  /* process command line arguments */
  command = argv[0];
  for (i = 1; i < argc; ++i) {
    arglen = strlen(argv[i]);
    if ( !strcmp(argv[i], "-I") ) {
      if ( (i+1)>=argc || !strncmp(argv[i+1], "-", 1)) {
	fprintf(stderr, "** No directory provided to %s in arguments %d.\n", argv[i], i);
	exit(1);
      }
      else {
	s = argv[++i];
	if ( IsDir(s.c_str()) ) {
	  if ( s[0] != '/' ) {
	    s = (string) getenv("PWD") + "/" + s;
	  }
	  paths.push_back(s);
	}
	else {
	  fprintf(stderr, "** Invalid path \"%s\" for -I in argument %d.\n", 
		  s.c_str(), i);
	  exit(1);
	}
      }
    }
//     if (arglen >= 2 && !strncmp(argv[i],"-I",2)) {
//       if (arglen == 2) {
// 	/* Perhaps we don't even need to notify user. */
// 	fprintf(stderr, "** No path for -I in argument %d.\n", i);
// 	exit(1);
//       }
//       else {
// 	s = argv[i];
// 	s = s.substr(2);
// 	if ( IsDir(s.c_str()) ) {
// 	  if ( s[0] != '/' ) {
// 	    s = (string) getenv("PWD") + "/" + s;
// 	  }
// 	  paths.push_back(s);
// 	}
// 	else {
// 	  fprintf(stderr, 
// 		  "** Invalid path \"%s\" for -I in argument %d.\n", 
// 		  s.c_str(), i);
// 	  exit(1);
// 	}
//       }
//     }
    else if ( !strcmp(argv[i], "-C") ) {
       CopyVerilogCode = true;
    }
    else if ( !strcmp(argv[i], "-o")) {
      if ((i+1)>=argc || !strncmp(argv[i+1], "-", 1)) {
	fprintf(stderr, "** No directory provided to %s in arguments %d.\n", argv[i], i);
	exit(1);
      }
      else {
	s = argv[++i];
	if ( workdir == "workdir" ) {
	  workdir = s; 
	}
	else {
	  fprintf(stderr, "** Multiple setting to output path, latest win. \nOrignal:%s Latest:%s\n", 
		  workdir.c_str(), s.c_str());
	  workdir = s;
	}
      }
    }
//     else if (arglen >=2 && !strncmp(argv[i], "-o", 2) ) {
//       if (arglen == 2) {
// 	/* Perhaps we don't even need to notify user. */
// 	fprintf(stderr, "** No path for -o in argument %d.\n", i);
// 	exit(1);
//       }
//       else {
// 	s = argv[i];
// 	s = s.substr(2);
// 	if ( workdir == "workdir" ) {
// 	  workdir = s; 
// 	}
// 	else {
// 	  fprintf(stderr, "** Multiple setting to output path, latest win. \nOrignal:%s Latest:%s\n", 
// 		  workdir.c_str(), s.c_str());
// 	  workdir = s;
// 	}
//       }
//     }	  
    else if ( !strcmp(argv[i], "-f")) 
      {
	if ( (i+1) >= argc || !strncmp(argv[i+1], "-", 1))
	  {
	    fprintf(stderr, "** No filelist provided to %s in arguments %d.\n", argv[i], i);
	    exit(1);
	  }
	else 
	  {
	    FILE *filelist = fopen(argv[++i], "r");
	    if ( filelist ) {
	      int lineno = 1;
	      size_t n = 0;
	      ssize_t l;
	      char *rawline  = NULL;
	      char *line; 
	      while ( (l=getline(&rawline, &n, filelist)) != -1 ) {
		line = NULL;
		if ( strcmp(rawline, "\n") && rawline[0] != '#' ) {
		  /* is NOT empty line or comment line*/
		  line = (char *) calloc(1, l+1);
		  if ( rawline[l-1] == '\n' ) {
		    strncpy(line, rawline, l-1);
		  }
		  else  {
		    strncpy(line, rawline, l);
		  }
		}

		if ( line ) {
		  cstr = SearchFile(line);
		  if ( cstr ) {
		    files.push_back(cstr);
		  }
		  else {
		    fprintf(stderr, 
			    "** File \"%s\" does not exist in filelist %s:%d in argument %d.\n", 
			    line, argv[i], lineno, i);
		    exit(1);
		  }
		}

		++lineno;
	      }
	    }
	    else {
	       fprintf(stderr, "** Invalid filelist %s in argument %d.\n",
		       argv[i], i);
	       exit(1);
	    }
	  }
      }
    else if ( !strcmp(argv[i], "-P" ) ) {
       if ( (i+1) >= argc || !strncmp(argv[i+1], "-", 1)) {
	  fprintf(stderr, "** No path list  provided to %s in arguments %d.\n", argv[i], i);
	  exit(1);
       }
       else {
	  FILE *pathlist = fopen(argv[++i], "r");
	  if ( pathlist ) {
	     int lineno = 1;
	     size_t n = 0;
	     ssize_t l;
	     char *rawline = NULL;
	     string line;
	     while ( (l=getline(&rawline, &n, pathlist)) != -1 ) {
		if ( strcmp(rawline, "\n") && rawline[0] != '#') {
		   /* is NOT empty line or comment line*/ 
		   line = rawline;
		   if ( line[line.length()-1] == '\n' ) {
		      line = line.substr(0, line.length()-1);
		   }
		   if ( IsDir(line.c_str() ) ) {
		      paths.push_back(line);
		   }
		   else {
		      fprintf(stderr, "** Invalid path \"%s\" in %s:%d, in arguments %d.\n", 
			      line.c_str(), argv[i], lineno, i);
		      exit(1);
		   }
		}
		++lineno;
	     }
	  }
	  else {
	     fprintf(stderr, "** ** Invalid pathlist %s in argument %d.\n",
		     argv[i], i);
	     exit(1);
	  }
       }


		   
    }
    else if (arglen >= 2 && !strncmp(argv[i], "-D", 2))
      {
	if (arglen == 2)
	  {
	    /* Perhaps we don't even need to notify user. */
	    fprintf(stderr, "** No define for -D in argument %d.\n", i);
	  }
	else
	  {
	    char *dname, *pnt;

	    dname = (char*) malloc( (arglen+8)*sizeof(char) ); // NMALLOC(arglen+8, char);
	    sprintf(dname, "`define %s", argv[i]+2);
	    pnt = dname+8;
	    while (*pnt)
	      {
		if (*pnt == '=')
		  {
		    *pnt = ' ';
		    break;
		  }
		pnt++;
	      }
	    store_define(dname);
	    free(dname);
	  }
      }
    else if (!strcmp(argv[i], "-E"))
      {
	/* Enable C style preprocessing of ifdef and friends. */
	output_ifdef_directive = 1;
      }
    else if (!strcmp(argv[i], "-CL")) 
      {
	OutputCodeLocation = true;
      }
    else if (!strcmp(argv[i], "-L"))
      {
	/* Write out `line directives for debugging. */
	output_line_directive = 0;
      }
    else if ( !strcmp(argv[i], "-F" ) ) {
       FastDependParse = true;
    }
    else if (!strcmp(argv[i], "-h"))
      {
	cout << "syntax: mhdlc [options] filename" << endl
	     << "options:" << endl
	     << "  -I         Specify sigle search path." << endl
	     << "  -D         Define macro as used in VCS or GCC." << endl
	     << "  -C         Copy V/SV codes touched by compiler into output dirctory." << endl
	   // << "  -E         NOT perform C style preprocessing." << endl
	     << "  -F         Fast dependency resolving, first found file win." << endl
	   // << "  -L         NOT output `line directive." << endl
	     << "  -P         Specify a list of search paths in a file." << endl
	     << "  -f         Specify a list of files to be processed." << endl
	     << "  -o         Specify output directory." << endl
	     << "  -verilog   Generate Verilog 2001 standard code." << endl
	     << "  --version  Display version information." << endl
	     << "  -h         Print this message." << endl;
	exit( 0 );
      }
    else if (!strcmp(argv[i], "--version")) 
      {
	 cout << "MetaHDL compiler " << mhdlversion.c_str() << endl
	      << "Copyright (C) 2010 MENG Xin, mengxin@vlsi.zju.edu.cn" << endl << endl;
	 exit(0);
      }
    else if (!strncmp(argv[i], "-d", 2) ) {
      s = argv[i];
      s = s.substr(2);
      if ( s == "ml" ) {
	DebugMHDLLexer = 1;
	mhdl_flex_debug = 1;
      }
      else if ( s == "mp" ) {
	DebugMHDLParser = 1;
      }
      else if ( s == "sl" ) {
	DebugSVLexer = 1;
	sv_flex_debug = 1;
      }
      else if ( s == "sp" ) {
	DebugSVParser = 1;
      }
      else if ( s == "pl") {
	DebugPPLexer = 1;
      }
      else {
	fprintf(stderr, 
		"** Invalid module to be debugged:\"%s\" in argument %d.\n", 
		s.c_str(), i);
      }
    }
    else if ( !strcmp(argv[i], "-verilog") ) {
      LEGACY_VERILOG_MODE = true;
    }
    else if ( !strncmp(argv[i], "-", 1) ) 
      {
	fprintf(stderr, "Unknown option: \"%s\"\n", argv[i]);
	exit(1);
      }
    else /* filename only.. */
      {
	cstr = SearchFile(argv[i]);
	if ( cstr ) {
	  files.push_back(cstr);
	}
	else {
	  fprintf(stderr, "** File \"%s\" does not exist in argument %d.\n", argv[i], i);
	  exit(1);
	}
      }
  }

  if (workdir[0] != '/' ) {
    s = getenv("PWD");
    if ( s == "/" ) {
      workdir = "/" + workdir;
    }
    else {
      workdir = s + "/" + workdir;
    }
  }
  if ( workdir.length() > 1 && workdir[workdir.length()-1] == '/' ) {
    workdir = workdir.substr(0, workdir.length()-1);
  }

  paths.push_back(workdir);

}

void
RptOpt(ostream &o)
{
  o << "MetaHDL version " << mhdlversion << endl
    << "Copyright (C), MENG Xin, mengxin@vlsi.zju.edu.cn" << endl
    << endl
    << "==============================" << endl
    << " Summary of working settings" << endl
    << "==============================" << endl
    << "Command: " << command << endl
    << "output_line_directive: " << output_line_directive << endl
    << "output_ifdef_directive: " << output_ifdef_directive << endl
    << "DebugMHDLLexer: " << DebugMHDLLexer << endl
    << "DebugMHDLParser: " << DebugMHDLParser << endl
    << "DebugSVLexer: " << DebugSVLexer << endl
    << "DebugSVParser: " << DebugSVParser << endl
    << "Workdir: " << workdir << endl
    << endl;

  o << endl
    << "===============================================" << endl
    << " " << paths.size() << " search paths specified with -I/-P option " << endl
    << "===============================================" << endl;
  for ( list<string>::iterator iter=paths.begin(); 
	iter != paths.end(); ++iter) {
    o << *iter << endl;
  }
  o << endl;

  o << "===================================" << endl
    << " " << files.size() << " files processed" << endl
    << "===================================" << endl;
  if ( files.empty() ) {
    o << "\t" << "(None)" << endl;
  }
  else {
    for ( vector<string>::iterator iter=files.begin(); iter != files.end(); ++iter) {
      o << (*iter) << endl;
    }
  }
}

void
CreateWorkdir()
{
  int cmd_status;
  string cmd;

  cmd = "mkdir -p " + workdir;
  cmd_status = system(cmd.c_str());
  if ( cmd_status != 0 ) {
    cerr << "**Cannot create working dir \"" << workdir << "\"!" << endl;
    exit(1);
  }
  
  FILE *t;
  t = fopen( (workdir + "/____MHDL_TEST_FILE____").c_str(), "w");
  if ( t ) {
    fclose(t);
    cmd_status = unlink( (workdir + "/____MHDL_TEST_FILE____").c_str() );
    if ( cmd_status ) {
      fprintf(stderr, "** Invalid workdir \"%s\", cannot remove file in it.\n", workdir.c_str());
      exit(1);
    }
  }
  else {
    fprintf(stderr, "** Invalid workdir \"%s\", cannot create file in it.\n", workdir.c_str());
    exit(1);
  }
}


tFileName
DecomposeName(const string &name)
{
  tFileName f;
  string s = name;
  size_t pos, pos_ ;

  pos = s.find_last_of("/");
  if ( pos == string::npos  ) {
    f.path = "";
    pos = 0;
  }
  else {
    f.path = s.substr(0, ++pos);
  }
  
  pos_ = s.find_last_of(".");
  if ( pos_ == string::npos ) {
    f.name  = s.substr(pos);
    f.ext   = "";
  }
  else {
    f.name  = s.substr(pos, pos_ - pos);
    f.ext   = s.substr(pos_);
  }

  return f;
}

/** my_eval_sv(code, error_check)
 ** kinda like eval_sv(), 
 ** but we pop the return value off the stack 
 **/
extern PerlInterpreter *my_perl;

SV* 
my_eval_sv(SV *sv, I32 croak_on_error)
{
  dSP;
  SV* retval;
  STRLEN n_a;

  PUSHMARK(SP);
  eval_sv(sv, G_SCALAR);

  SPAGAIN;
  retval = POPs;
  PUTBACK;

  if (croak_on_error && SvTRUE(ERRSV))
    croak(SvPVx(ERRSV, n_a));

  return retval;
}

string 
regexp_substitute(const string &str, const string &pattern)
{

  string cmd_str = "$string = '" + str + "'; ($string =~ " + pattern + ");";

  STRLEN n_a;
  SV *cmd_sv = newSVpvf(cmd_str.c_str());
  
  SV *retval;

  retval = my_eval_sv(cmd_sv, TRUE);
  SvREFCNT_dec(cmd_sv);

  string result_str;
  result_str = SvPV(get_sv("string", FALSE), n_a);
  return result_str;
}
