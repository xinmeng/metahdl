#!/usr/bin/python3
import teelog
import argparse

AP = argparse.ArgumentParser(parents=[teelog.AP])

# --------------------------------------------------
# Language independent options
# --------------------------------------------------
AP.add_argument('--stop-at', default='all',
                choices=['include', 'pp', 'all'],
                help='Stop processing when the specified stage is finished')

# --------------------------------------------------
#  Pre-processor options
# --------------------------------------------------
AP.add_argument('--incdir', '-incdir', '--include', '-include', '-I',
                dest='incdir', action='append', default=[],
                help="Add include directory")
AP.add_argument('--mhdl-base', '-mb',
                dest='mhdl_base', action='append', default = ['.', ],
                help='Specify MetaHDL source base directory')
AP.add_argument('--ip-base', '-ib',
                dest='ip_base', action='append', default = ['.', ],
                help='Specify one or more IP base directories')
AP.add_argument('--output-directory', '-o', action='store', default='.', metavar='DIR',
                help="Output directory for generated verilog")

AP.add_argument('--define', '-define', '-D', action='append',
                help="Define a macro that will override same macro in source code")

AP.add_argument('--keep-postpp-file', action='store_true', 
                help='Post preprocessor files are not deleted for debug purpose')

AP.add_argument('--legacy-pp-mode', action='store_true', 
                help="Enable the legacy MPP mode, in which `for and `let are not supported")

AP.add_argument('--debug-mpp-lex', action='store_true', 
                help="Enable debug on lexer of MetaHDL Preprocessor")
AP.add_argument('--debug-mpp-yacc', action='store_true',
                help="Enable debug on yacc of MetaHDL Preprocessor")
AP.add_argument('--debug-mpp-parser', action='store_true', 
                help='Enable debug on parser of MetaHDL Preprocessor')
AP.add_argument('--enable-mpp-tracking', action='store_true',
                help='Enable line number tracking in MetaHDL preprocessor parser')

# --------------------------------------------------
#  MetaHDL Options
# --------------------------------------------------
AP.add_argument('--debug-mhdl-lex', action='store_true',
                help="Enable debug on lexer of MetaHDL")
AP.add_argument('--debug-mhdl-yacc', action='store_true',
                help="Enable debug on yacc of MetaHDL")
AP.add_argument('--debug-mhdl-parser', action='store_true', 
                help='Enable debug on parser of MetaHDL')
AP.add_argument('--disable-mhdl-tracking', action='store_true',
                help='Disable line number tracking in MetaHDL paser')

AP.add_argument('--case-modifier', default='macro', 
                choices=['macro', 'propagate', 'eliminate'], 
                help="Alter the 'unique' case modifier in the generated verilog")

AP.add_argument('--no-sanity-check', action='append', metavar='FSM_NAME',
                help="Modules that don't need sanity check code generation")

AP.add_argument('--mhdl-ctrl', action='append', metavar="var=value",
                help='Sepcify key-value pairs of MetaHDL control variables to control the runtime behavior of MetaHDL parser')


# --------------------------------------------------
#  Lint options
# --------------------------------------------------
AP.add_argument('--enable-rule', '-en', action='append', metavar='Rule-XXX',
                help='Enable a specific Lint rule')

AP.add_argument('--disable-rule', '-dis', action='append', metavar='Rule-XXX',
                help='Disable a specific Lint rule')


# --------------------------------------------------
#  SystemVerilog options
# --------------------------------------------------
AP.add_argument('--debug-sv-lex', action='store_true',
                help="Enable debug on lexer of SystemVerilog")
AP.add_argument('--debug-sv-yacc', action='store_true',
                help="Enable debug on yacc of SystemVerilog")
AP.add_argument('--debug-sv-parser', action='store_true', 
                help='Enable debug on parser of SystemVerilog')
AP.add_argument('--disable-sv-tracking', action='store_true',
                help='Disable line number tracking in SystemVerilog Parser')

AP.add_argument('--copy-verilog', action='store_true', 
                help='The expanded verilog files are copied to destination diectory')



# --------------------------------------------------
#  Files to be processed
# --------------------------------------------------
AP.add_argument('files', action='append',
                help='Files to be processed')



if __name__ == '__main__':
    args=AP.parse_args()
    print(args)

