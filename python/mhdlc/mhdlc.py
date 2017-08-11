#!/usr/bin/python3

import os
import sys
sys.path.append(os.environ["HOME"] +"/mxmf/projects/scripts/python/")
sys.path.append(os.environ["HOME"] +"/mxmf/projects/metahdl/python/ply/3.8")

import mhdlcUtility
import mhdlcOpt



import DirFile
import ParserFactory


class Mhdlc:
    total_count = 0
    compiler_id = 0

    def __init__(self, args):
        self.args = args
        self.args.log_header_name = True
        mhdlcOpt.teelog.Setup(self.args)
        self.logging = mhdlcOpt.teelog.logging

        Mhdlc.total_count += 1
        self.compiler_id = Mhdlc.total_count
        if self.compiler_id != 1:
            self.namesuffix = "-{}".format(self.compiler_id)
        else :
            self.namesuffix = ''
        
        self.log = self.logging.getLogger("mhdlc" + self.namesuffix)
        self.log.debug("Create mhdlc No.{0}:{1}".format(self.compiler_id, self.args))

        # self is passed to instances for access common resources
        self.dirfile  = mhdlcUtility.DirFile(self)
        self.include  = ParserFactory.CreateIncludeParser(self)
        self.mpp      = ParserFactory.CreateMPPParser(self)
        self.mhdl     = ParserFactory.CreateMHDLparser(self)
        self.sv       = ParserFactory.CreateSVparser(self)
        
    def Parse(self):
        for srcfile in self.args.files:
            suffix  = self.DirFile.GetSuffix(srcfile)
            post_include = self.include.Parse(srcfile)
            if self.args.stop_at == 'include':
                dstfile = self.DirFile.GetOutputFile(srcfile, '.post_inc')
                dstfile.write(post_include)
        
            post_mpp = self.mpp.Parse(post_include)
            if self.args.stop_at == 'mpp':
                dstfile = self.DirFile.GetOutputFile(srcfile, '.post_mpp')
                dstfile.write(post_mpp)
        
            if suffix == '.mhdl':
                post_mhdl = self.mhdl.Parse(post_mpp)
                dstfile = self.DirFile.GetOutputFile(srcfile, '.v')
                dstfile.write(post_mhdl)
            else: # suffix in ('.sv', '.v', '.SV', '.v', '.vh', '.h'):
                post_sv = self.sv.Parse(post_mpp)
            


if __name__ == '__main__':
    args = mhdlcOpt.AP.parse_args()
    x = mhdlc(args)

