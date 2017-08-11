#!/usr/bin/python3
import pathlib
import re

class DirFile:
    def __init__(self, mhdlc):
        self.mhdlc = mhdlc
        self.log   = self.mhdlc.logging.getLogger("DirFile" + self.mhdlc.namesuffix)
        self.base  = {'mhdl':list(), 'ip':list()}
        self.search_path = {'mhdl':list(), 'ip':list()}
        self.search_cache = dict()
        self.SetIncDir()
        self.SetOutputDir()
        self.SetBaseDir('mhdl')
        self.SetBaseDir('ip')
        

    def SetIncDir(self):
        self.incdir = list()
        if self.mhdlc.args.incdir is not None:
            for d in self.mhdlc.args.incdir:
                try: 
                    abspath = pathlib.Path(d).resolve()
                except FileNotFoundError:
                    self.log.error("Directory '{0}' does not exist".format(d))
                    exit
                except RuntimeError:
                    self.log.error("Infinite loop detected on {0}:{1}".format(d, 
                                                                              RuntimeError))
                    exit
                else:
                    self.log.debug("Add include directory: {0}".format(abspath))
                    self.incdir.append(abspath)


    def SetOutputBase(self):
        output_directory = self.mhdlc.args.output_directory
        try: 
            self.obase = pathlib.Path(output_directory).resolve()
            self.log.debug("Set output directory {0}".format(self.obase))
        except FileNotFoundError:
            pathlib.Path(output_directory).mkdir(mode=0o755, parents=True)
            self.obase = pathlib.Path(output_directory).resolve()
            self.log.debug("Create output directory {0}".format(self.obase))
        except RuntimeError:
            self.log.error("Infinite loop detected on {0}:{1}".format(d, RuntimeError))
            exit


    def SetBaseDir(self, sel):
        dirs = self.mhdlc.args.ip_base if sel == 'ip' else self.mhdlc.args.mhdl_base
        if dirs is not None:
            for d in dirs:
                try:
                    base = pathlib.Path(d).resolve()
                except FileNotFoundError:
                    self.log.error("Base directory '{0}' does not exist".format(d))
                except RuntimeError:
                    self.log.error("Infinite loop detected on {0}:{1}".format(d, RuntimeError))
                else:
                    self.log.debug("Add base[{0}] directory {1}".format(sel, base))
                    self.base[sel].append(base);
                    self.SetSearchPath(base, sel)


    def SetSearchPath(self, base, sel):
        for d in base.rglob('*'):
            if d.is_dir() and not d.match('.git') and not d.match('.svn'):
                self.search_path[sel].append(d)
                self.log.debug("Add search_path[{0}] directories {1}".format(sel, d))


    def IsMHDL(self, filename):
        p = pathlib.PurePath(filename)
        if re.match(p.suffix, r'\.mhdl', flags=re.I):
            return True
        else:
            return False

    def IsSV(self, filename):
        p = pathlib.PurePath(filename)
        if re.match(p.suffix, r'\.sv', flags=re.I):
            return True
        else:
            return False

    def IsHeader(self, filename):
        p = pathlib.PurePath(filename)
        if re.match(p.suffix, r'\.(v|vh)', flags=re.I):
            return True
        else:
            return False
        

    def SearchFile(self, filename, base_sel, cache_sel):
        if filename[0] == '/':
            f = pathlib.Path(filename)
            if f.exists():
                return open(f)
            else:
                return None
        elif self.search_cache.get(cache_sel):
            f = pathlib.Path(self.search_cache[cache_sel] + '/' + filename)
            if f.exists():
                return open(f)
            else:
                for d in self.search_path[base_sel]:
                    f = pathlib.Path(d + '/' + filename)
                    if f.exists():
                        self.search_cache[cache_sel] = d
                        return open (f)
                else:
                    return None
                

    def GetFile(self, filename):
        if filename[0] == '/':
            return open(filename)
        else:
            if self.IsMHDL(filename):
                found = self.SearchFile(filename, 'mhdl', 'mhdl')
            elif self.IsSV(filename):
                found = self.SearchFile(filename, 'ip', 'ip')
                if not found:
                    found = self.SearchFile(filename, 'mhdl', 'mhdl_sv')
            else:
                found = self.SearchFile(filename, 'ip', 'header')
                if not found:
                    found = self.SearchFile(filename, 'mhdl', 'header')
            if found:
                return found
            else:
                self.log.error("Can't find {}.".format(filename))
                exit 
                    
            
            

    def GetSuffix(self):
        srcfile = pathlib.PurePath(srcfile)
        suffix = srcfile.suffix
        suffix = suffix[1:] # remove dot
        suffix = suffix.lower()
        return suffix

    def GetOutputDir(self, srcfile):
        srcfile = pathlib.PurePath(srcfile)
        fdir   = srcfile.parent
        fname  = srcfile.name
        suffix = srcfile.suffix
        dstdir = ''
        for mbase in self.base['mhdl']:
            try:
                subdir = dir.relative_to(mbase)
            except ValueError:
                self.log.debug("{0} is not under {1}".format(fdir, mbase))
            else:
                dstdir = self.obase + '/' + subdir
        else:
            dstdir = self.obase
        pathlib.Path(outdir).mkdir(mode=0o755, parents=True)
        return outdir

    def GetOutputFile(self, srcfile, suffix):
        outdir   = self.GetOutputDir(srcfile)
        srcfile  = pathlib.PurePath(srcfile)
        basename = srcfile.stem
        dstfile  = outdir + '/' + basename + suffix
        return open(dstfile, 'w')
    



class Position: 
    def __init__(self, pos=None):
        if pos:
            self.file = pos.file
            self.ln   = pos.ln
            self.col  = pos.col
        else:
            self.file = ""
            self.ln   = 1
            self.col  = 1

    def __add__(self, tok):
        self.ln  = tok.lineno
        self.col = 
            
            
class IncludeParser:
    def __init__(self, mhdlc):
        self.mhdlc = mhdlc

    def Parse(self, filename):
        lineno = 1
        


if __name__ == '__main__':
    import teelog

    local_ap = argparse.ArgumentParser(parents=[AP, teelog.AP])
    args = local_ap.parse_args()
    teelog.Setup(args)

    Setup(args,teelog.logging.getLogger('DirFile'))
