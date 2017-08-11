#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <limits.h>
#include <errno.h>

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
void ReportDefines(ostream &o);


// global option variables
char PATH_BUF [PATH_MAX];

int DebugPPLexer = 0;
int DebugMHDLLexer  = 0;
int DebugMHDLParser = 0;
int DebugSVLexer  = 0;
int DebugSVParser = 0;
bool FastDependParse = false;
bool CopyVerilogCode = false;
bool LEGACY_VERILOG_MODE = false;
bool FORCE_WIDTH_OUTPUT = false;
bool OutputCodeLocation = false;
bool PreservePostPPFile = false;
enum e_case_modify_style_t CASE_MODIFY_STYLE = PROPAGATE;

set<string> NO_SANITY_CHECK;

// global variables
// extern class CModTab;
// extern CModTab G_ModuleTable;

string COMMAND = "";
vector<string> FILES;
list<string>   PATHS, M_DIRS, I_DIRS;
map<string, string> MIRROR;
string M_BASE = ".";
set<string> I_BASE; // = ""; 
string V_BASE = "../rtl";
//string WORKDIR = "workdir";

string LOGFILE = "";
string mhdlversion = "3.0";


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


string 
GetRealpath(const string &path)
{
    string msg;
    string abspath;

    if (realpath(path.c_str(), PATH_BUF)) 
        abspath = PATH_BUF;
    else {
        msg = "Error:Can't call realpath() on '" + path +"'";
        perror(msg.c_str());
        exit(1);
    }

    return abspath;
}

list<string> 
GetSubdir(string base)
{
    string msg, cmd, dir;
    FILE *dirlist;
    list<string> dirs;


    // base = GetRealpath(base);
    cmd = "find -L " + base + " -type d";

    dirlist = popen(cmd.c_str(), "r");
    if (!dirlist) {
        msg = "Error:'" + cmd + "' execution fail";
        perror(msg.c_str());
        exit(1);
    }
    else {
        while (fgets(PATH_BUF, PATH_MAX, dirlist)) {
            dir = PATH_BUF;
            dir = dir.substr(0, dir.length()-1); // remove trailing "\n"
            // cout << dir << endl;
            dirs.push_back(dir);
        }
    }
    pclose(dirlist);

    return dirs;    
}


map<string, string>
CreateMirrorDir(const string &mbase, const string &vbase, list<string> dirs)
{
    string msg, mdir, vdir;
    map<string, string> mirror;

    for (list<string>::iterator iter=dirs.begin(); iter != dirs.end(); iter++) {
        mdir = *iter;

        if (mdir == mbase) {
            vdir = vbase;
        }
        else {
            vdir = mdir;
            vdir.replace(0, mbase.length(), vbase);
            // if (vbase.length() == 1)
            //     vdir.replace(0, mbase.length(), "");
            // else
            //     vdir.replace(0, mbase.length(), vbase);
        }
        mirror[mdir] = vdir;
        // cout << mdir << " -> " << vdir << endl;


        if (mkdir(vdir.c_str(), S_IRWXU | S_IRGRP | S_IXGRP | S_IROTH | S_IXOTH) ) {
            if (errno != EEXIST) {
                msg = "Error:mirror from '" + mbase + "' to '" + vbase + "' fail upon '" + vdir;
                perror(msg.c_str());
                exit(1);
            }
        }
    }

    return mirror;
}


char *
SearchFile(const char *name)
{
    string sname = name;
    return SearchFile(sname);
}

char *
SearchFile(const string &name)
{
    char *path;
    string s;

    /* absolut path, or relative path,
     * check file existance  */
    if ( IsFile(name.c_str()) ) {
        path = (char *)calloc(1, strlen(name.c_str())+1);
        strcpy(path, name.c_str());
        return path;
    }
    /* otherwise, search file in paths */
    else {
        string extention;
        size_t pos = name.find_last_of(".");
        list<string> *dirs;
        if (pos == string::npos) 
            extention = "";
        else 
            extention = name.substr(pos);
        
        if (extention == ".mhdl") {
            dirs = &M_DIRS;
        }
        else {
            dirs = &I_DIRS;
        }

        string dir;
        for ( list<string>::iterator iter = dirs->begin(); 
              iter != dirs->end(); ++iter ) {
            dir = *iter;
            if ( dir[dir.length()-1] == '/' ) {
                s = dir + name;
            }
            else {
                s = dir + "/" + name;
            }
      
            if ( IsFile( s.c_str() ) ) {
                dirs->erase(iter);
                dirs->push_front(dir);

                path = (char *)calloc(1, strlen(s.c_str())+1);
                strcpy(path, s.c_str());
                return path;
            }
        }
        return NULL;
    }
}


void UseOutputPathFromENV()
{
  // char *s = getenv("METAHDL_OUTPUT_PATH");
  
  // if ( !s ) 
  //   return;
  // else {
  //   string path = s;
    
  //   size_t pos = path.find_first_of(' ');
    
  //   if ( pos != string::npos ) 
  //     path = path.substr(0, pos-1);

  //   WORKDIR = path;
  // }
}

void 
AddSearchPathFromENV()
{
  char * s = getenv("METAHDL_SEARCH_PATH");
  
  string env_paths;

  if ( s ) 
    env_paths = s;
  else 
    return;
  
  size_t start =0; 
  size_t end = 0;
  char last_char = env_paths[end];

  string path;
  while (end < env_paths.length()) {
    if ( env_paths[end] == ' ' && last_char == ' ')  {
      start = end;
      end++;
    }
    else if (env_paths[end] == ' ' && last_char != ' ') {
      path = env_paths.substr(start, end-start);
      if ( IsDir(path.c_str()) ) 
	PATHS.push_back(path);
      else {
	fprintf(stderr, "**mhdlc error: %s is not valid directory in $METAHDL_SEARCH_PATH.\n", path.c_str());
	exit(1);
      }

      last_char = ' ';
      end++;
    }
    else if (env_paths[end] != ' ' && last_char == ' ') {
      start = end;
      last_char = env_paths[end];
      end++;
    }
    else {
      end++;
    }
  }
  
  if ( start != env_paths.length() - 1) {
    path = env_paths.substr(start, end-start);
    if ( IsDir(path.c_str()) ) 
      PATHS.push_back(path);
    else {
      fprintf(stderr, "**mhdlc error: %s is not valid directory in $METAHDL_SEARCH_PATH.\n", path.c_str());
      exit(1);
    }
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
  // PATHS.push_back(getenv("PWD"));

  /* load environment vairables */
  AddSearchPathFromENV();
  UseOutputPathFromENV();


  /* process command line arguments */
  COMMAND = argv[0];
  for (i = 1; i < argc; ++i) {
    arglen = strlen(argv[i]);
    if ( !strcmp(argv[i], "-I") ) {
      if ( (i+1)>=argc || !strncmp(argv[i+1], "-", 1)) {
	fprintf(stderr, "**mhdlc error: No directory provided to %s in arguments %d.\n", argv[i], i);
	exit(1);
      }
      else {
	s = argv[++i];
	if ( IsDir(s.c_str()) ) {
	  if ( s[0] != '/' ) {
	    s = (string) getenv("PWD") + "/" + s;
	  }
	  PATHS.push_back(s);
	}
	else {
	  fprintf(stderr, "**mhdlc error: Invalid path \"%s\" for -I in argument %d.\n", 
		  s.c_str(), i);
	  exit(1);
	}
      }
    }
    else if ( !strcmp(argv[i], "-C") ) {
       CopyVerilogCode = true;
    }
    else if ( !strcmp(argv[i], "-o")) {
      if ((i+1)>=argc || !strncmp(argv[i+1], "-", 1)) {
	fprintf(stderr, "**mhdlc error: No directory provided to %s in arguments %d.\n", argv[i], i);
	exit(1);
      }
      else {
          V_BASE = argv[++i];
          if (!IsDir(V_BASE.c_str())) {
              fprintf(stderr, "**mhdlc error: output directory '%s' in arguments %d doesn't exist.\n", V_BASE.c_str(), i);
              exit(1);
          }          
      }
    }
    else if ( !strncmp(argv[i], "-l", 2) ) {
      s = argv[i];
      s = s.substr(2);
      if ( s == "" ) {
	fprintf(stderr, "**mhdlc error: No log file name provided to %s in arguments %d.\n", argv[i], i);
	exit(1);
      }
      else {
	LOGFILE = s;
      }
    }
    else if ( !strcmp(argv[i], "-f")) {
	if ( (i+1) >= argc || !strncmp(argv[i+1], "-", 1)) {
	    fprintf(stderr, "**mhdlc error: No filelist provided to %s in arguments %d.\n", argv[i], i);
	    exit(1);
        }
	else {
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
		    FILES.push_back(cstr);
		  }
		  else {
		    fprintf(stderr, 
			    "**mhdlc error: File \"%s\" does not exist in filelist %s:%d in argument %d.\n", 
			    line, argv[i], lineno, i);
		    exit(1);
		  }
		}

		++lineno;
	      }
	    }
	    else {
	       fprintf(stderr, "**mhdlc error: Invalid filelist %s in argument %d.\n",
		       argv[i], i);
	       exit(1);
	    }
	  }
      }
    // else if ( !strcmp(argv[i], "-P" ) ) {
    //    if ( (i+1) >= argc || !strncmp(argv[i+1], "-", 1)) {
    //       fprintf(stderr, "**mhdlc error: No path list  provided to %s in arguments %d.\n", argv[i], i);
    //       exit(1);
    //    }
    //    else {
    //       FILE *pathlist = fopen(argv[++i], "r");
    //       if ( pathlist ) {
    //          int lineno = 1;
    //          size_t n = 0;
    //          ssize_t l;
    //          char *rawline = NULL;
    //          string line;
    //          while ( (l=getline(&rawline, &n, pathlist)) != -1 ) {
    //     	if ( strcmp(rawline, "\n") && rawline[0] != '#') {
    //     	   /* is NOT empty line or comment line*/ 
    //     	   line = rawline;
    //     	   if ( line[line.length()-1] == '\n' ) {
    //     	      line = line.substr(0, line.length()-1);
    //     	   }
    //     	   if ( IsDir(line.c_str() ) ) {
    //     	      PATHS.push_back(line);
    //     	   }
    //     	   else {
    //     	      fprintf(stderr, "**mhdlc error: Invalid path \"%s\" in %s:%d, in arguments %d.\n", 
    //     		      line.c_str(), argv[i], lineno, i);
    //     	      exit(1);
    //     	   }
    //     	}
    //     	++lineno;
    //          }
    //       }
    //       else {
    //          fprintf(stderr, "**mhdlc error: Invalid pathlist %s in argument %d.\n",
    //     	     argv[i], i);
    //          exit(1);
    //       }
    //    }
    // }
    else if (arglen >= 2 && !strncmp(argv[i], "-D", 2)) {
	if (arglen == 2)  {
	    /* Perhaps we don't even need to notify user. */
	    fprintf(stderr, "**mhdlc error: No define for -D in argument %d.\n", i);
	    exit(1);
        }
	else {
	    char *dname, *pnt;

	    dname = (char*) malloc( (arglen+8)*sizeof(char) ); // NMALLOC(arglen+8, char);
	    sprintf(dname, "`define %s", argv[i]+2);
	    pnt = dname+8;
	    while (*pnt)  {
		if (*pnt == '=')  {
		    *pnt = ' ';
		    break;
                }
		pnt++;
            }
	    store_define(dname);
	    free(dname);
        }
    }
    else if (!strcmp(argv[i], "-E")) {
	/* Enable C style preprocessing of ifdef and friends. */
	output_ifdef_directive = 1;
    }
    else if (!strcmp(argv[i], "-CL")) {
	OutputCodeLocation = true;
    }
    else if (!strcmp(argv[i], "-L")) {
	/* Write out `line directives for debugging. */
	output_line_directive = 0;
    }
    else if ( !strcmp(argv[i], "-F" ) ) {
       FastDependParse = true;
    }
    else if ( !strcmp(argv[i], "--propagate-case-modifier") ) {
      CASE_MODIFY_STYLE = PROPAGATE;
    }
    else if ( !strcmp(argv[i], "--macro-case-modifier") ) {
      CASE_MODIFY_STYLE = MACRO;
    }
    else if ( !strcmp(argv[i], "--eliminate-case-modifier")) {
      CASE_MODIFY_STYLE = ELIMINATE;
    }
    else if ( !strcmp(argv[i], "--preserve-postpp-file")) {
      PreservePostPPFile = true;
    }
    else if ( !strcmp(argv[i], "-mb")) {
        if ( (i+1)>=argc || !strncmp(argv[i+1], "-", 1)) {
            fprintf(stderr, "**mhdlc error: No directory provided to %s in arguments %d.\n", argv[i], i);
            exit(1);
        }
        else {
            M_BASE = argv[++i];
            if ( !IsDir(M_BASE.c_str()) ) {
                fprintf(stderr, "**mhdlc error: Invalid path \"%s\" for -mb in argument %d.\n", M_BASE.c_str(), i);
                exit(1);
            }
        }
    }
    else if ( !strcmp(argv[i], "-ib") ) {
        if ( (i+1)>=argc || !strncmp(argv[i+1], "-", 1)) {
            fprintf(stderr, "**mhdlc error: No directory provided to %s in arguments %d.\n", argv[i], i);
            exit(1);
        }
        else {
            s = argv[++i];
            if ( IsDir(s.c_str()) ) {
                if (I_BASE.count(s) == 0) {
                    // I_BASE.insert(GetRealpath(s));
                    I_BASE.insert(s);
                }
            }
            else {
                fprintf(stderr, "**mhdlc error: Invalid path \"%s\" for -I in argument %d.\n", s.c_str(), i);
                exit(1);
            }
        }
    }
    else if ( !strcmp(argv[i], "--no-sanity-check")) {
        if ( (i+1)>=argc || !strncmp(argv[i+1], "-", 1)) {
            fprintf(stderr, "**mhdlc error: No name provided to %s in argument %d.\n", argv[i], i);
            exit(1);
        }
        else {
            s = argv[++i];
            NO_SANITY_CHECK.insert(s);
        }
    }
    else if (!strcmp(argv[i], "-h"))
      {
	cout << "syntax: mhdlc [options] filename" << endl
	     << "options:" << endl
	     << "  -I         Specify sigle MetaHDL search path. " << endl
             << "  -mb        Specify MetaHDL Base directory, all subdirectoies are searched." << endl
             << "  -ib        Specify IP Base directory, all subdirectoies are searched." << endl
	     << "  -D         Define macro as used in VCS or GCC." << endl
	     << "  -C         Copy V/SV codes touched by compiler into output dirctory." << endl
	     << "  -CL        Output code location for cross referencing between .v/.sv and .mhdl source." << endl
	     << "  -E         Preserve macro after preprocessing." << endl
	     << "  -F         Fast dependency resolving, first found file win." << endl
	     << "  -L         NOT output `line directive from preprocessor" << endl
            // << "  -P         Specify a list of search paths in a file." << endl
	     << "  -f         Specify a list of files to be processed." << endl
	     << "  -o         Specify output base directory." << endl
	     << "             METAHDL_OUTPUT_PATH environment variable." << endl
	     << "  -lXXX      Output summary of current compilation into log file XXX." << endl
	     << endl
	     << "  --force-width-output" << endl
	     << "             This option forces width attached to every signal in generated codes, even when " << endl
	     << "             designers deliberately ommit width on a bus variable." << endl
	     << endl
	     << "  -verilog   Generate Verilog 2001 standard code. 'case' statement has three different outputs" << endl
	     << "             controlled by following three options:" << endl
	     << endl
	     << "    --propagate-case-modifier" << endl
	     << "             'unique' and 'priority' case modifiers are preserved in generated verilog source code."  << endl
	     << "             This is the default behavior." << endl
	     << endl
	     << "    --macro-case-modifier" << endl
	     << "             'unique' and 'priority' case modifiers are enclosed in `NO_UNIQUE' macro in " << endl
	     << "             generated verilog source code, which lets simulation or synthesis process to decide" << endl
	     << "             the usage of the modifiers." << endl
	     << endl
	     << "    --eliminate-code-modifiers" << endl
	     << "             'unique' and 'priority' case modifiers are removed in generated verilog source code." << endl
	     << endl
	     << endl
	     << "  --version  Display version information." << endl
	     << "  -env       Display values of METAHDL_SEARCH_PATH and METAHDL_OUTPUT_PATH." << endl
	     << "  -h         Print this message." << endl;
	exit( 0 );
      }
    else if (!strcmp(argv[i], "--version")) 
      {
	 cout << "MetaHDL compiler " << mhdlversion.c_str() << endl
	      << "Copyright (C) 2010 MENG Xin, xinmeng@hotmail.com" << endl << endl;
	 exit(0);
      }
    else if (!strcmp(argv[i], "-env")) {
      cout << "METAHDL_SEARCH_PATH: " << endl;
      if ( getenv("METAHDL_SEARCH_PATH") ) 
	cout << getenv("METAHDL_SEARCH_PATH") << endl;
      else 
	cout << "";

      cout << endl;

      cout << "METAHDL_OUTPUT_PATH:" << endl;
      if ( getenv("METAHDL_OUTPUT_PATH") ) 
	cout << getenv("METAHDL_OUTPUT_PATH") << endl;
      else 
	cout << "";

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
		"**mhdlc error: Invalid module to be debugged:\"%s\" in argument %d.\n", 
		s.c_str(), i);
	exit(1);
      }
    }
    else if ( !strncmp(argv[i], "+dump2D+", 8) ) {
      
    }
    else if ( !strcmp(argv[i], "--force-width-output" ) ) {
      FORCE_WIDTH_OUTPUT = true;
    }
    else if ( !strcmp(argv[i], "-verilog") ) {
      LEGACY_VERILOG_MODE = true;
    }
    else if ( !strncmp(argv[i], "-", 1) ) 
      {
	fprintf(stderr, "Unknown option: \"%s\"\n", argv[i]);
	exit(1);
      }
    else { /* filename only.. */
        cstr = argv[i];
        FILES.push_back(cstr);
	// cstr = SearchFile(argv[i]);
	// if ( cstr ) {
        //     FILES.push_back(cstr);
	// }
	// else {
        //     fprintf(stderr, "**mhdlc error: File \"%s\" does not exist in argument %d.\n", argv[i], i);
        //     exit(1);
	// }
    }
  }

  if (I_BASE.size() != 0)
      for (set<string>::iterator iter = I_BASE.begin(); 
           iter != I_BASE.end(); iter++) {
          list<string> i_dirs = GetSubdir(*iter);
          I_DIRS.insert(I_DIRS.end(), i_dirs.begin(), i_dirs.end());
      }

  // M_BASE = GetRealpath(M_BASE);
  M_DIRS = GetSubdir(M_BASE);

  // V_BASE = GetRealpath(V_BASE);
  MIRROR = CreateMirrorDir(M_BASE, V_BASE, M_DIRS);
//  PATHS.insert(PATHS.end(), M_DIRS.begin(), M_DIRS.end());
  M_DIRS.insert(M_DIRS.end(), PATHS.begin(), PATHS.end());
  I_DIRS.insert(I_DIRS.end(), PATHS.begin(), PATHS.end());

  for (map<string,string>::iterator iter=MIRROR.begin(); iter != MIRROR.end(); iter++)
      I_DIRS.push_back( iter->second);
  
  // if (WORKDIR[0] != '/' ) {
  //   s = getenv("PWD");
  //   if ( s == "/" ) {
  //     WORKDIR = "/" + WORKDIR;
  //   }
  //   else {
  //     WORKDIR = s + "/" + WORKDIR;
  //   }
  // }
  // if ( WORKDIR.length() > 1 && WORKDIR[WORKDIR.length()-1] == '/' ) {
  //   WORKDIR = WORKDIR.substr(0, WORKDIR.length()-1);
  // }

  // PATHS.push_back(WORKDIR);

}

void
RptOpt()
{
  if (LOGFILE == "" ) return;

  ofstream os;
  os.open(LOGFILE.c_str(), ios_base::out);
  if ( ! os.is_open() ) {
    cerr << "** Error: Cannot open log file \"" << LOGFILE << "\" for write." << endl;
    exit(1);
  }

  os << "MetaHDL version " << mhdlversion << endl
     << "Copyright (C), MENG Xin, mengxin@vlsi.zju.edu.cn" << endl
     << endl
     << "==============================" << endl
     << " Summary of working settings" << endl
     << "==============================" << endl
     << "Command: " << COMMAND << endl
     << "output_line_directive: " << output_line_directive << endl
     << "output_ifdef_directive: " << output_ifdef_directive << endl
     << "DebugMHDLLexer: " << DebugMHDLLexer << endl
     << "DebugMHDLParser: " << DebugMHDLParser << endl
     << "DebugSVLexer: " << DebugSVLexer << endl
     << "DebugSVParser: " << DebugSVParser << endl
     << endl;


  ReportDefines(os);

  os << endl
     << "===============================================" << endl
     << " " << PATHS.size() << " MetaHDL search paths specified with -I/-mb option" << endl
     << "  or METAHDL_SEARCH_PATH environment variable" << endl
     << "===============================================" << endl;
  for ( list<string>::iterator iter=PATHS.begin(); 
	iter != PATHS.end(); ++iter) {
    os << *iter << endl;
  }
  os << endl;

  os << "===================================" << endl
     << " " << I_DIRS.size() << " IP search paths processed" << endl
     << "===================================" << endl;
  for (list<string>::iterator iter=I_DIRS.begin();
       iter != I_DIRS.end(); ++iter) {
      os << *iter << endl;
  }
  os << endl;

  os << "===================================" << endl
     << " " << M_DIRS.size() << " MetaHDL search paths processed" << endl
     << "===================================" << endl;
  for (list<string>::iterator iter=M_DIRS.begin();
       iter != M_DIRS.end(); ++iter) {
      os << *iter << endl;
  }
  os << endl;

  os << "===================================" << endl
     << " " << FILES.size() << " files processed" << endl
     << "===================================" << endl;
  if ( FILES.empty() ) {
    os << "\t" << "(None)" << endl;
  }
  else {
    for ( vector<string>::iterator iter=FILES.begin(); iter != FILES.end(); ++iter) {
      os << (*iter) << endl;
    }
  }


  os.close();

}

void
CreateWorkdir()
{
  // int cmd_status;
  // string cmd;

  // cmd = "mkdir -p " + WORKDIR;
  // cmd_status = system(cmd.c_str());
  // if ( cmd_status != 0 ) {
  //   cerr << "**mhdlc error:Cannot create working dir \"" << WORKDIR << "\"!" << endl;
  //   exit(1);
  // }
  
  // FILE *t;
  // t = fopen( (WORKDIR + "/____MHDL_TEST_FILE____").c_str(), "w");
  // if ( t ) {
  //   fclose(t);
  //   cmd_status = unlink( (WORKDIR + "/____MHDL_TEST_FILE____").c_str() );
  //   if ( cmd_status ) {
  //     fprintf(stderr, "**mhdlc error: Invalid workdir \"%s\", cannot remove file in it.\n", WORKDIR.c_str());
  //     exit(1);
  //   }
  // }
  // else {
  //   fprintf(stderr, "**mhdlc error: Invalid workdir \"%s\", cannot create file in it.\n", WORKDIR.c_str());
  //   exit(1);
  // }
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

int
regexp_match(const string &str, const string &pattern)
{
  string cmd_str = "$string = '" + str + "'; $string =~ " + pattern + ";";

  SV *cmd_sv = newSVpvf(cmd_str.c_str());
  SV *retval;
 
  retval = my_eval_sv(cmd_sv, TRUE);
  SvREFCNT_dec(cmd_sv);
 
  return SvIV(retval);
}


string
ItoS(ulonglong num, int width, int base)
{
  assert (base == 2 || base == 10 || base == 16);

  if ( base == 2 ) {
    string str;
    int rmd;

    do {
      rmd = num % 2;
      if ( rmd ) str = "1" + str;
      else str = "0" + str;
    }  while ( num = num / 2 ) ;
  
    if ( width < 0 || str.length() == width )  {
      return str;
    }
    else if ( str.length() > width ) {
      str = str.substr(str.length() - width);
      return str;
    }
    else if ( str.length() < width ) {
      string pad;
      for ( int i = 0; i<width-str.length(); ++i) {
	pad += "0";
      }
      str = pad + str;
      return str;
    }
  }
  else {
    stringstream sstr;
    sstr << setbase(base)
	 << num;
    return sstr.str();
  }
}

ulonglong
StoI(const string &str, int base)
{
  assert(base == 2 || base == 10 || base == 16);

  string s = str;
  string::iterator iter1 = s.begin(); 

  while ( iter1 != s.end() ) {
    for ( string::iterator iter = s.begin(); 
	  iter != s.end(); iter++) {
      if (*iter == '_' ) {
	s.erase(iter);
	iter1 = s.begin();
	break;
      }
      else {
	++iter1;
      }
    }
  }
  return (ulonglong) strtoll(s.c_str(), NULL, base);
}
