class BaseParser:
    precedence = (
        ('right', 'QUESTION_MARK', 'COLON'),
        ('left', 'COND_OR'),
        ('left', 'COND_AND'),
        ('left', 'LOGIC_OR'),
        ('left', 'LOGIC_XOR'),
        ('left', 'LOGIC_AND'),
        ('left', 'COND_EQ', 'COND_NE'),
        ('left', 'COND_LT', 'COND_LE', 'COND_GT', 'COND_GE'),
        ('left', 'SHIFT_LEFT', 'SHIFT_RIGHT'),
        ('left', 'BINARY_ADD', 'BINARY_SUB'),
        ('left', 'BINARY_MUL', 'BINARY_DIV', 'BINARY_MOD'),
        ('right', 'COND_NOT', 'LOGIC_NOT', 'UNARY_AND', 'UNARY_OR', 'UNARY_XOR'),
    )

    def p_empty(self, p):
        '''empty :'''
        pass

    def p_expression_constant(self, p):
        '''expression : constant_expression'''
        pass

    def p_constant_number(self, p):
        '''constant_expression : number
                               | constant_array
                               | constant_dup
                               | STRING'''
        pass

    def p_number(self, p):
        '''number : BASED_NUMBER
                  | INT_NUMBER
                  | FLOAT_NUMBER'''
        pass

    def p_const_array(self, p):
        '''constant_array : SINGLE_QUOTE constant_concatenation'''
        pass

    def p_constant_concatenation(self, p):
        '''constant_concatenation : L_BRACE constant_expressions R_BRACE'''
        pass

    def p_constant_expressions(self, p):
        '''constant_expressions : constant_expression
                                | constant_expressions COMMA constant_expression'''
        pass

    def p_constant_dup(self, p):
        '''constant_dup : SINGLE_QUOTE L_BRACE INT_NUMBER constant_concatenation R_BRACE'''
        pass



    def p_expression_primary(self, p):
        '''expression : expression_primary'''
        pass

    def p_primary(self, p):
        '''expression_primary : ID 
                              | ID dimensions'''
        pass
    
    def p_dimensions(self, p):
        '''dimensions : dimension 
                      | dimensions dimension'''
        pass
    
    def p_dimension(self, p):
        '''dimension : L_BRACKET dim_index R_BRACKET
                     | L_BRACKET dim_bounded R_BRACKET
                     | L_BRACKET dim_range R_BRACKET'''
        pass

    def p_dim_index(self, p):
        '''dim_index : expression'''
        pass

    def p_dim_bounded(self, p):
        '''dim_bounded : expression COMMA expression'''
        pass

    def p_dim_range(self, p):
        '''dim_range : expression BINARY_ADD COMMA expression
                     | expression BINARY_SUB COMMA expression'''
        pass

    def p_expression_concatenation(self, p):
        '''expression : expression_concatenation'''
        pass

    def p_concat(self, p):
        '''expression_concatenation : L_BRACE expressions R_BRACE'''
        pass

    def p_expressions(self, p):
        '''expressions : expression
                       | expressions COMMA expression'''
        pass

    def p_expression_dup(self, p):
        '''expression : L_BRACE expression expression_concatenation R_BRACE'''
        pass

    def p_expression_group(self, p):
        '''expression : L_PAREN expression R_PAREN'''
        pass

    def p_expression_binary_exp(self, p):
        '''expression : expression_logic_bin_exp
                      | expression_cond_bin_exp
                      | expression_arith_bin_exp'''
        pass

    def p_expression_logic_bin_exp(self, p):
        '''expression_logic_bin_exp : expression LOGIC_OR expression
                                    | expression LOGIC_AND expression 
                                    | expression LOGIC_XOR expression'''
        pass

    def p_expression_cond_bin_exp(self, p):
        '''expression_cond_bin_exp : expression COND_OR expression
                                   | expression COND_AND expression
                                   | expression COND_EQ expression
                                   | expression COND_NE expression
                                   | expression COND_LT expression
                                   | expression COND_LE expression
                                   | expression COND_GT expression
                                   | expression COND_GE expression'''
        pass

    def p_expression_arith_bin_exp(self, p):
        '''expression_arith_bin_exp : expression BINARY_ADD expression
                                    | expression BINARY_SUB expression
                                    | expression BINARY_MUL expression
                                    | expression BINARY_DIV expression
                                    | expression BINARY_MOD expression
                                    | expression SHIFT_LEFT expression
                                    | expression SHIFT_RIGHT expression'''
        pass

    def p_expression_unary_exp(self, p):
        '''expression : expression_cond_unary_exp 
                      | expression_logic_unary_exp'''
        pass

    def p_expression_cond_unary_exp(self, p):
        '''expression_cond_unary_exp : COND_NOT expression'''
        pass

    def p_expression_logic_unary_exp(self, p):
        '''expression_logic_unary_exp : LOGIC_NOT expression 
                                      | LOGIC_OR expression %prec UNARY_OR
                                      | LOGIC_AND expression %prec UNARY_AND
                                      | LOGIC_XOR expression %prec UNARY_XOR'''
        pass

    
    def p_expression_tri_op(self, p):
        '''expression : expression QUESTION_MARK expression COLON expression'''
        pass
