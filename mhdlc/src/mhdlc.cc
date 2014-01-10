#include "MetaHDL.hh"
#include <fstream>
#include <iostream>
using namespace std;

#include <sys/times.h>
#include <sys/time.h>

#include <EXTERN.h>
#include <perl.h>


CModTab G_ModuleTable;
CNumber* CONST_NUM_0 = new CNumber(32, 0);



extern string LOGFILE;

PerlInterpreter *my_perl;

int main(int argc, char *argv[])
{
  timeval start, end;
  gettimeofday( &start, NULL);


  GetOpt(argc, argv);
  // CreateWorkdir();
  RptOpt(); // report option if "-log" is presented
  

  // for embeded perl
  char *embedding[] = { "", "-e", "0" };
  PERL_SYS_INIT3(NULL,NULL,NULL);
  my_perl = perl_alloc();
  perl_construct(my_perl);
  perl_parse(my_perl, NULL, 3, embedding, NULL);
  PL_exit_flags |= PERL_EXIT_DESTRUCT_END;



  // process files
  ulonglong file_cnt = FILES.size();
  for (ulonglong i = 0; i < file_cnt; ++i ) {
      char *fname;
      string dir_file;
      if (fname = SearchFile(FILES[i])) 
          dir_file = fname;
      else {
          fprintf(stderr, "**mhdlc:Can't find file '%s'.\n", fname);
          exit(1);
      }
          
      tFileName f = DecomposeName( dir_file );

    CMHDLwrapper *mwrapper;
    CSVwrapper *svwrapper;
    if (f.ext == ".mhdl") {
      cerr << "\n" << i+1 << "/" << file_cnt << " Parsing MHDL file:" << dir_file << endl;
      mwrapper = new CMHDLwrapper (dir_file);
      mwrapper->Parse();
    }
    else {
      cerr << "\n" << i+1 << "/" << file_cnt << " Parsing SV file:" << dir_file << endl;
      svwrapper = new CSVwrapper (dir_file);
      svwrapper->Parse();
    }
  }

  
  if (LOGFILE != "") {
    ofstream os;
    os.open(LOGFILE.c_str(), ios_base::app);

      os << endl
         << endl
         << "==================================" << endl
         << " " << G_ModuleTable.Size() << " modules got during this run  " << endl
         << "==================================" << endl;
  
      G_ModuleTable.Print(os);

      os.close();
  }

  // free perl
  PL_perl_destruct_level = 1;
  perl_destruct(my_perl);
  perl_free(my_perl);
  PERL_SYS_TERM();



  // report time used
  gettimeofday( &end, NULL);

  struct tms time_used;
  clock_t t = times(&time_used);
  long CLK_PER_SEC = sysconf(_SC_CLK_TCK);
  if ( t == -1 ) {
    cerr << "Times overflow." << endl;
  }
  else {
    cerr << endl 
	 << "*********************************************************" << endl
	 << "   M e t a H D L   C o m p i l e r   f i n i s h e d" << endl
	 << endl
	 << "    CPU Time: " << (double) time_used.tms_utime / CLK_PER_SEC << " sec" << endl
	 << " System Time: " << (double) time_used.tms_stime / CLK_PER_SEC << " sec" << endl
	 << "   User Time: " << end.tv_sec - start.tv_sec << " sec" << endl
	 << "      output: " << V_BASE << endl
	 << endl
	 << "*********************************************************" << endl;
  }

  return 0;
}
